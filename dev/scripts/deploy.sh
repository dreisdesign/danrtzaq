#!/bin/bash

# Deploy script for danreisdesign.com and postsforpause.com
# This script deploys local changes to the remote server with backup and safety checks
#
# Usage:
#   ./deploy.sh          # Regular deployment
#   ./deploy.sh --dry-run  # Test run without making changes
#
# Safety features:
# - Creates backup before deployment
# - Checks file sizes
# - Validates permissions
# - Clears cache after deployment

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Check required commands
for cmd in rsync ssh ssh-add find sed mktemp; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: Required command '$cmd' not found"
        exit 1
    fi
done

# Configuration
REMOTE_USER="danrtzaq"
REMOTE_HOST="danreisdesign.com"
REMOTE_PORT="21098"
ROOT_DIR="/Users/danielreis/web/danrtzaq"
SSH_KEY="$HOME/.ssh/id_rsa"
BACKUP_DIR="$ROOT_DIR/dev/backups/$(date '+%Y-%m-%d_%H-%M-%S')"

# Site configurations
SITES=("public_html" "postsforpause.com")
SITE_PATHS=("/home/danrtzaq/public_html" "/home/danrtzaq/postsforpause.com")

# Parse arguments
DRY_RUN=0
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run) DRY_RUN=1 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

# Create log directory
LOG_DIR="$ROOT_DIR/dev/logs/deploy"
LOG_FILE="$LOG_DIR/deploy-$(date '+%Y-%m-%d_%H-%M-%S').log"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

# Add dry-run indicator to commands
DRY_RUN_PREFIX=""
[[ $DRY_RUN -eq 1 ]] && DRY_RUN_PREFIX="[DRY RUN] "

# Update echo commands to include prefix
echo "${DRY_RUN_PREFIX}=== Starting deployment at $(date) ==="
[[ $DRY_RUN -eq 1 ]] && echo "DRY RUN MODE - No changes will be made"

# Colors for terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting deployment process...${NC}"

# Backup function
create_backup() {
    local dir=$1
    local backup_path="$BACKUP_DIR/$(basename "$dir")"
    echo "Creating backup of $dir to $backup_path"
    mkdir -p "$backup_path"
    rsync -a "$dir/" "$backup_path/"
}

# Add this function after the create_backup function:
format_html_files() {
  local dir=$1
  echo "Checking HTML formatting in $dir..."

  # Find all HTML files
  find "$dir" -name "*.html" -type f -print0 | while IFS= read -r -d $'\0' file; do
    # Standardize indentation to 2 spaces
    if grep -q "    " "$file"; then
      echo "Formatting: $file"
      # Create a temporary file
      tmp_file=$(mktemp)
      # Convert 4 spaces to 2 spaces for indentation
      sed 's/    /  /g' "$file" > "$tmp_file"
      mv "$tmp_file" "$file"
    fi
  done
}

# Validation and backup
for local_dir in "${SITES[@]}"; do
    if [ ! -d "$ROOT_DIR/$local_dir" ]; then
        echo "Error: Required directory $local_dir not found!"
        exit 1
    fi

    if [[ $DRY_RUN -eq 0 ]]; then
        # Format HTML files for consistent indentation
        format_html_files "$ROOT_DIR/$local_dir"
        # Create backup
        create_backup "$ROOT_DIR/$local_dir"
    fi
done

# SSH error handling
handle_ssh_error() {
    echo "Error: SSH operation failed!"
    echo "Please check your SSH connection and try again."
    exit 1
}
trap 'handle_ssh_error' ERR

# Add SSH key
eval $(ssh-agent -s)
ssh-add "$SSH_KEY"

# Function to update cache busters and last updated dates
update_cache_busters() {
    local dir=$1
    local timestamp=$(date +%Y%m%d-%H%M)
    local date_human=$(date '+%A, %B %d, %Y at %l:%M%p' | sed 's/  / /g')
    local files_changed=0
    local changes=()

    echo "Updating cache busters and timestamps in $dir..."

    # Find all HTML files
    while IFS= read -r file; do
        local rel_path="${file#$dir/}"
        local orig_hash=$(md5sum "$file" | cut -d' ' -f1)
        local temp_file=$(mktemp)

        # Update multiple asset types
        sed -E \
            -e "s/(\.js|\.css|\.svg)\?v=[0-9]{8}-[0-9]{3,4}/\1?v=$timestamp/g" \
            -e "s/(\.js|\.css|\.svg)\"/\1?v=$timestamp\"/g" \
            -e "s/<!-- Last updated:.*-->/<!-- Last updated: $date_human -->/" \
            "$file" > "$temp_file"

        # Only update if changes were made
        local new_hash=$(md5sum "$temp_file" | cut -d' ' -f1)
        if [ "$orig_hash" != "$new_hash" ]; then
            mv "$temp_file" "$file"
            changes+=("$rel_path")
            files_changed=1
        else
            rm "$temp_file"
        fi
    done < <(find "$dir" -type f -name "*.html")

    # Process CSS files to update @import statements
    while IFS= read -r file; do
        local rel_path="${file#$dir/}"
        local orig_hash=$(md5sum "$file" | cut -d' ' -f1)
        local temp_file=$(mktemp)

        # Update @import statements in CSS files
        sed -E \
            -e "s/@import ['\"](.+\.css)['\"];/@import '\1?v=$timestamp';/g" \
            -e "s/@import ['\"](.+\.css)\?v=[0-9]{8}-[0-9]{3,4}['\"];/@import '\1?v=$timestamp';/g" \
            "$file" > "$temp_file"

        # Only update if changes were made
        local new_hash=$(md5sum "$temp_file" | cut -d' ' -f1)
        if [ "$orig_hash" != "$new_hash" ]; then
            mv "$temp_file" "$file"
            changes+=("$rel_path (CSS imports)")
            files_changed=1
        else
            rm "$temp_file"
        fi
    done < <(find "$dir" -type f -name "*.css")

    # Report changes in a cleaner format
    if [ ${#changes[@]} -gt 0 ]; then
        echo "Updated files:"
        printf '  ✓ %s\n' "${changes[@]}"
    else
        echo "ℹ️  No files needed cache buster updates"
    fi
}

# Modify the rsync command to support dry-run
RSYNC_OPTS="-avz --delete --delete-excluded"
[[ $DRY_RUN -eq 1 ]] && RSYNC_OPTS="$RSYNC_OPTS --dry-run"

# Add size limit check
MAX_SIZE_MB=500
check_size() {
    local dir=$1
    local size_mb=$(du -sm "$dir" | cut -f1)
    if [ "$size_mb" -gt "$MAX_SIZE_MB" ]; then
        echo "❌ Error: $dir is ${size_mb}MB, exceeding limit of ${MAX_SIZE_MB}MB"
        exit 1
    fi
    echo "✅ Size check passed: $dir is ${size_mb}MB"
}

# Add size check before deployment
for local_dir in "${SITES[@]}"; do
    check_size "$ROOT_DIR/$local_dir"
done

# Update validation function for critical files with site-specific checks
validate_critical_files() {
    local dir=$1
    local site=$(basename "$dir")

    echo "Validating critical files in $dir..."

    # Common critical files for all sites
    local common_files=(".htaccess" "index.html")

    # Site-specific critical files using case statement instead of associative array
    local site_files=""
    case "$site" in
        "public_html")
            site_files="robots.txt sitemap.xml"
            ;;
        "postsforpause.com")
            site_files="robots.txt"
            ;;
    esac

    # Check common files
    for file in "${common_files[@]}"; do
        if [ ! -f "$dir/$file" ]; then
            echo "❌ Error: Critical file missing: $file"
            exit 1
        fi
        echo "✓ Found $file"
    done

    # Check site-specific files
    if [ -n "$site_files" ]; then
        for file in $site_files; do
            if [ ! -f "$dir/$file" ]; then
                echo "⚠️  Warning: Site-specific file missing: $file"
            else
                echo "✓ Found $file"
            fi
        done
    fi
}

# Update validation function to show cleaner output
validate_cache_busters() {
    local dir=$1
    local timestamp=$2
    local issues_found=0
    local warnings=()
    local validated=()

    echo "Validating cache busters in $dir..."

    while IFS= read -r file; do
        local rel_path="${file#$dir/}"
        local file_issues=0

        # Check for required elements
        if grep -q "\.(js|css|svg)\"" "$file" && ! grep -q "\.(js|css|svg)?v=" "$file"; then
            warnings+=("$rel_path (missing asset versioning)")
            file_issues=1
        fi

        if ! grep -q "<!-- Last updated:" "$file"; then
            warnings+=("$rel_path (missing timestamp)")
            file_issues=1
        fi

        if [ $file_issues -eq 0 ]; then
            validated+=("$rel_path")
        fi
    done < <(find "$dir" -type f -name "*.html")

    # Report results
    if [ ${#validated[@]} -gt 0 ]; then
        echo "Validated files:"
        printf '  ✓ %s\n' "${validated[@]}"
    fi

    if [ ${#warnings[@]} -gt 0 ]; then
        echo "Warnings:"
        printf '  ⚠️  %s\n' "${warnings[@]}"
        return 1
    fi

    return 0
}

# Add detailed logging for file changes
log_file_changes() {
    local dir=$1
    echo -e "\n=== File Changes Summary ==="
    echo "Modified HTML files:"
    find "$dir" -type f -name "*.html" -mmin -1 -ls

    echo -e "\nModified CSS/JS files:"
    find "$dir" \( -name "*.css" -o -name "*.js" \) -mmin -1 -ls
}

# Create robots.txt if missing
create_robots_txt() {
    local dir=$1
    local site=$(basename "$dir")

    if [ ! -f "$dir/robots.txt" ]; then
        echo "Creating missing robots.txt for $site"
        cat > "$dir/robots.txt" << EOF
User-agent: *
Allow: /
Sitemap: https://${site}.com/sitemap.xml
EOF
    fi
}

# Deploy each site
for i in "${!SITES[@]}"; do
    local_dir="${SITES[$i]}"
    remote_dir="${SITE_PATHS[$i]}"
    timestamp=$(date +%Y%m%d-%H%M)

    echo -e "\n${DRY_RUN_PREFIX}=== Deploying $local_dir to $remote_dir ==="

    # Add validation checks
    validate_critical_files "$ROOT_DIR/$local_dir"

    # Create robots.txt if missing
    create_robots_txt "$ROOT_DIR/$local_dir"

    # Update cache busters with validation
    update_cache_busters "$ROOT_DIR/$local_dir" "$timestamp"
    validate_cache_busters "$ROOT_DIR/$local_dir" "$timestamp"

    # Create basic filter file
    FILTER_FILE=$(mktemp)
    cat > "$FILTER_FILE" << EOF
- /.DS_Store
- /._*
- /**/.DS_Store
- /**/._*
- /.git/***
- /node_modules/***
- /.cache/***
- /dev/***
- /**/package*.json
- /**/gulpfile.js
+ /**/
+ /**
EOF

    # Perform sync
    rsync $RSYNC_OPTS \
        --filter="merge $FILTER_FILE" \
        -e "ssh -p $REMOTE_PORT" \
        "$ROOT_DIR/$local_dir/" \
        "$REMOTE_USER@$REMOTE_HOST:$remote_dir/" || {
            echo "Error: Rsync failed for $local_dir"
            rm "$FILTER_FILE"
            exit 1
        }

    rm "$FILTER_FILE"

    # Set permissions only if not in dry-run mode
    if [[ $DRY_RUN -eq 0 ]]; then
        echo "Setting permissions for $remote_dir"
        ssh -p $REMOTE_PORT "$REMOTE_USER@$REMOTE_HOST" \
            "chmod -R u=rwX,g=rX,o=rX '$remote_dir'" || {
                echo "Error: Failed to set permissions for $remote_dir"
                exit 1
            }
    fi

    # Add change logging
    log_file_changes "$ROOT_DIR/$local_dir"
done

# Clear server cache
ssh -p $REMOTE_PORT "$REMOTE_USER@$REMOTE_HOST" '
    echo "Clearing server cache...";
    for dir in public_html postsforpause.com; do
        if [ -f "/home/danrtzaq/$dir/.htaccess" ]; then
            touch "/home/danrtzaq/$dir/.htaccess";
            echo "Refreshed .htaccess in $dir";
        fi
    done

    if [ -d "/home/danrtzaq/tmp/cache" ]; then
        rm -rf /home/danrtzaq/tmp/cache/*;
        echo "Server cache cleared";
    fi
'

# Add deployment summary before website opening
echo -e "\n${DRY_RUN_PREFIX}=== Deployment Summary ==="
echo "📂 Files processed:"
for i in "${!SITES[@]}"; do
    local_dir="${SITES[$i]}"
    echo "  ✓ ${local_dir}: $(find "$ROOT_DIR/$local_dir" -type f | wc -l) files"
done

echo "🔒 Permissions:"
for i in "${!SITES[@]}"; do
    remote_dir="${SITE_PATHS[$i]}"
    echo "  ✓ ${remote_dir}: u=rwX,g=rX,o=rX"
done

echo "🔄 Cache:"
echo "  ✓ .htaccess files refreshed"
echo "  ✓ Server cache cleared"

# Website URLs
MAIN_SITE="https://danreisdesign.com"
POSTS_SITE="https://postsforpause.com"

# Function to open URLs in default browser
open_websites() {
    echo "Opening websites in default browser..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        open "$MAIN_SITE"
        open "$POSTS_SITE"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        xdg-open "$MAIN_SITE"
        xdg-open "$POSTS_SITE"
    else
        echo "Unknown operating system, cannot open browser automatically"
    fi
}

# Open websites after deployment
echo "=== Opening websites in browser ==="
open_websites

echo "=== Deployment with cache invalidation completed at $(date) ==="
echo "Log saved to $LOG_FILE"
[[ $DRY_RUN -eq 1 ]] && echo "This was a dry run - no changes were made"

echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${YELLOW}REMINDER: Don't forget to commit your changes to GitHub.${NC}"
echo -e "Use: git add . && git commit -m \"Update site with latest changes\" && git push"

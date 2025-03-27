#!/bin/bash

# Backup tool for downloading remote sites
# Downloads files from danreisdesign.com with size checks and progress tracking
#
# Usage:
#   ./download_site.sh              # Download public_html
#   ./download_site.sh --dir=postsforpause.com  # Download specific site
#   ./download_site.sh --dry-run    # Test run without downloading

# Exit on error and undefined variables
set -eu

# Configuration
REMOTE_USER="danrtzaq"
REMOTE_HOST="danreisdesign.com"
REMOTE_PORT="21098"
BACKUP_DIR="/Users/danielreis/web/danrtzaq/dev/backups/$(date '+%Y-%m-%d_%H-%M-%S')"
LOG_DIR="/Users/danielreis/web/danrtzaq/dev/logs/downloads"
LOG_FILE="$LOG_DIR/download-$(date '+%Y-%m-%d_%H-%M-%S').log"

# Create necessary directories
mkdir -p "$BACKUP_DIR" "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

# Parse arguments
DRY_RUN=0
DIRECTORY="public_html"
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run) DRY_RUN=1 ;;
        --dir=*) DIRECTORY="${1#*=}" ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

echo "=== Starting download at $(date) ==="
[[ $DRY_RUN -eq 1 ]] && echo "DRY RUN MODE - No files will be downloaded"

# Get file count and size estimation first
echo "Calculating files and size..."
ssh -p $REMOTE_PORT "$REMOTE_USER@$REMOTE_HOST" "cd /home/danrtzaq/$DIRECTORY && du -sh . && find . -type f | wc -l"

# Add size limit check
MAX_SIZE_MB=500
check_remote_size() {
    local size_mb=$(ssh -p $REMOTE_PORT "$REMOTE_USER@$REMOTE_HOST" "du -sm /home/danrtzaq/$DIRECTORY" | cut -f1)
    if [ "$size_mb" -gt "$MAX_SIZE_MB" ]; then
        echo "❌ Error: Remote directory is ${size_mb}MB, exceeding limit of ${MAX_SIZE_MB}MB"
        exit 1
    fi
    echo "✅ Size check passed: Remote directory is ${size_mb}MB"
}

# Add size check before download
check_remote_size

# Prepare rsync options with better progress indicators
RSYNC_OPTS="-avz --progress --stats --human-readable --info=progress2"
[[ $DRY_RUN -eq 1 ]] && RSYNC_OPTS="$RSYNC_OPTS --dry-run"

# Add download progress function
print_progress() {
    echo -ne "\rProgress: $1 transferred | Speed: $2/s | ETA: $3"
}

# Add more specific excludes based on the log analysis
EXCLUDES=(
    '.DS_Store'
    '._*'
    '.git'
    'node_modules'
    'tmp'
    '*.bak'
    '.cache'
    'dev/logs'
)

# Build exclude options
EXCLUDE_OPTS=""
for excl in "${EXCLUDES[@]}"; do
    EXCLUDE_OPTS="$EXCLUDE_OPTS --exclude='$excl'"
done

# Download files with improved command
echo "Downloading /home/danrtzaq/$DIRECTORY to $BACKUP_DIR/$DIRECTORY"
eval "rsync $RSYNC_OPTS \
    -e 'ssh -p $REMOTE_PORT' \
    $EXCLUDE_OPTS \
    '$REMOTE_USER@$REMOTE_HOST:/home/danrtzaq/$DIRECTORY/' \
    '$BACKUP_DIR/$DIRECTORY/'" || {
        echo "Error: Download failed"
        exit 1
    }

# Add download summary
echo -e "\n=== Download Summary ==="
echo "📂 Source: $REMOTE_USER@$REMOTE_HOST:/home/danrtzaq/$DIRECTORY/"
echo "📂 Destination: $BACKUP_DIR/$DIRECTORY/"
echo "📊 Statistics:"
echo "   Size: $(du -sh "$BACKUP_DIR/$DIRECTORY" | cut -f1)"
echo "   Files: $(find "$BACKUP_DIR/$DIRECTORY" -type f | wc -l)"
echo "   Directories: $(find "$BACKUP_DIR/$DIRECTORY" -type d | wc -l)"
echo "   Total items: $(find "$BACKUP_DIR/$DIRECTORY" | wc -l)"

echo -e "\n=== Download completed at $(date) ==="
echo "Files saved to: $BACKUP_DIR/$DIRECTORY"
echo "Log saved to: $LOG_FILE"

# Cleanup old backups (keep last 5)
find "$(dirname "$BACKUP_DIR")" -maxdepth 1 -type d -name "20*" | sort -r | tail -n +6 | xargs rm -rf 2>/dev/null || true

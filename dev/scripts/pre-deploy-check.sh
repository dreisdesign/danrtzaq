#!/bin/bash

# Pre-deployment check script for danreisdesign.com
# This script performs checks before deployment to ensure everything is ready

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Root directory
ROOT_DIR="/Users/danielreis/web/danrtzaq"
SITES=("public_html" "postsforpause.com")

echo "=== Running pre-deployment checks ==="

# 1. Check that the portfolio JSON is up-to-date
echo "Checking portfolio data..."
if [ -f "$ROOT_DIR/public_html/data/portfolio-items.json" ]; then
    # Get file modification time
    FILE_MOD_TIME=$(stat -f "%m" "$ROOT_DIR/public_html/data/portfolio-items.json")
    CURRENT_TIME=$(date +%s)
    # Calculate days since last update
    DAYS_SINCE_UPDATE=$(( (CURRENT_TIME - FILE_MOD_TIME) / 86400 ))
    
    if [ $DAYS_SINCE_UPDATE -gt 7 ]; then
        echo "⚠️  Warning: Portfolio data is $DAYS_SINCE_UPDATE days old. Consider running 'npm run build:portfolio'"
    else
        echo "✓ Portfolio data is up-to-date."
    fi
else
    echo "⚠️  Warning: Portfolio data file not found! Run 'npm run build:portfolio' to generate it."
    echo "  To continue without portfolio data, press Enter."
    read -p ""
fi

# 2. Check for required directories
for site in "${SITES[@]}"; do
    if [ ! -d "$ROOT_DIR/$site" ]; then
        echo "❌ Error: Required directory $site not found!"
        exit 1
    fi
    
    # Check for index.html in root of each site
    if [ ! -f "$ROOT_DIR/$site/index.html" ]; then
        echo "❌ Error: Missing index.html in $site!"
        exit 1
    fi
    
    echo "✓ Directory $site exists and contains index.html"
done

# 3. Check for uncommitted git changes
if [ -d "$ROOT_DIR/.git" ]; then
    if ! git -C "$ROOT_DIR" diff --quiet; then
        echo "⚠️  Warning: You have uncommitted changes in git."
        echo "  Consider committing your changes before deploying."
        echo "  To continue anyway, press Enter."
        read -p ""
    else
        echo "✓ No uncommitted git changes found."
    fi
fi

# Final confirmation
echo ""
echo "=== Pre-deployment check completed ==="
echo ""
echo "Ready to deploy. Press Ctrl+C to abort or Enter to continue."
read -p ""

exit 0

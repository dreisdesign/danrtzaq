#!/bin/bash

# Script to specifically fix the platform-asset-flexibility page issues
# Usage: ./fix-platform-asset-flexibility.sh

set -e

HTML_FILE="/Users/danielreis/web/danrtzaq/public_html/portfolio/mikmak/platform-asset-flexibility/index.html"

echo "Fixing issues in $HTML_FILE..."

if [ -f "$HTML_FILE" ]; then
    # Create a backup
    cp "$HTML_FILE" "${HTML_FILE}.bak"
    
    # Fix the content-caption and list issue
    sed -i '' 's/<p class="content-caption"><b>Communicating Feature Enhancements vs Legacy<\/b>\s*<ol>/<div class="content-caption"><b>Communicating Feature Enhancements vs Legacy<\/b>\n  <ol>/g' "$HTML_FILE"
    sed -i '' 's/<\/ol>\s*<\/p>/<\/ol>\n  <\/div>/g' "$HTML_FILE"
    
    echo "✓ Fixed specific issues in platform-asset-flexibility page"
else
    echo "❌ Error: File not found: $HTML_FILE"
    exit 1
fi

echo "🔍 Fix complete! Backup saved at ${HTML_FILE}.bak"

#!/bin/bash

# Script to ONLY format HTML files with prettier (no fixes or modifications)
# Usage: ./format-html-only.sh [directory-or-file]

set -e

# Base directory and defaults
BASE_DIR="/Users/danielreis/web/danrtzaq"
TARGET="${1:-"$BASE_DIR/public_html"}"

# Check if prettier is installed
if ! command -v prettier &> /dev/null; then
    echo "❌ Prettier is not installed. Please install it using:"
    echo "npm install -g prettier"
    exit 1
fi

echo "===== HTML Format Only ====="

# Format function for a single file
format_html_file() {
    local file=$1
    echo "Formatting HTML file: $(basename "$file")"
    prettier --write --print-width 100 --html-whitespace-sensitivity ignore "$file"
    echo "✓ $(basename "$file") formatted"
}

# Count total files to be processed
count_files() {
    if [ -d "$1" ]; then
        find "$1" -name "*.html" -type f | wc -l
    else
        echo 1
    fi
}

total_files=$(count_files "$TARGET")
echo "Found $total_files HTML files to format"

# Process target (file or directory)
if [ -d "$TARGET" ]; then
    echo "Processing directory: $TARGET"
    find "$TARGET" -name "*.html" -type f | while read -r file; do
        format_html_file "$file"
    done
elif [ -f "$TARGET" ]; then
    if [[ "$TARGET" == *.html ]]; then
        format_html_file "$TARGET"
    else
        echo "❌ File is not an HTML file: $TARGET"
        exit 1
    fi
else
    echo "❌ Target not found: $TARGET"
    exit 1
fi

echo "✅ HTML formatting complete!"

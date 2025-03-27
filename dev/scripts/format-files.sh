#!/bin/bash

# Script to format all web files in your project
# Requires prettier to be installed globally (npm install -g prettier)

echo "===== File Formatting Helper ====="
echo "Starting formatting process..."

# Base directory 
BASE_DIR="/Users/danielreis/web/danrtzaq"
PUBLIC_HTML_DIR="$BASE_DIR/public_html"
POSTS_DIR="$BASE_DIR/postsforpause.com"

# Check if prettier is installed
if ! command -v prettier &> /dev/null; then
    echo "❌ Prettier is not installed. Please install it using:"
    echo "npm install -g prettier"
    exit 1
fi

# Fix common HTML issues first
echo "Fixing HTML issues..."
bash "$BASE_DIR/dev/scripts/fix-html-issues.sh" "$PUBLIC_HTML_DIR"
bash "$BASE_DIR/dev/scripts/fix-html-issues.sh" "$POSTS_DIR"

# Apply HTML indentation fix
echo "Fixing HTML indentation with format-html.sh..."
bash "$BASE_DIR/dev/scripts/format-html.sh" "$PUBLIC_HTML_DIR"
bash "$BASE_DIR/dev/scripts/format-html.sh" "$POSTS_DIR"

# Format HTML files
echo "Formatting HTML files with Prettier..."
find "$PUBLIC_HTML_DIR" -name "*.html" -print0 | xargs -0 -n 1 prettier --write --print-width 100 --html-whitespace-sensitivity ignore
find "$POSTS_DIR" -name "*.html" -print0 | xargs -0 -n 1 prettier --write --print-width 100 --html-whitespace-sensitivity ignore

# Format CSS files
echo "Formatting CSS files..."
find "$PUBLIC_HTML_DIR" -name "*.css" -print0 | xargs -0 -n 1 prettier --write
find "$POSTS_DIR" -name "*.css" -print0 | xargs -0 -n 1 prettier --write

# Format JavaScript files
echo "Formatting JavaScript files..."
find "$PUBLIC_HTML_DIR" -name "*.js" -print0 | xargs -0 -n 1 prettier --write
find "$POSTS_DIR" -name "*.js" -print0 | xargs -0 -n 1 prettier --write

echo "✅ Formatting complete!"

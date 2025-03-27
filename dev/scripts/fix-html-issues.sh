#!/bin/bash

# Script to fix common HTML issues found in portfolio files
# Usage: ./fix-html-issues.sh [file-or-directory]

set -e

# Get the absolute path of the script's directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/../.."

# If no target is provided, default to the public_html directory
DEFAULT_TARGET="$PROJECT_ROOT/public_html"
TARGET="${1:-$DEFAULT_TARGET}"

# Replace relative path with absolute path if needed
if [[ "$TARGET" == ../* ]]; then
    TARGET="$SCRIPT_DIR/$TARGET"
fi

echo "Script directory: $SCRIPT_DIR"
echo "Project root: $PROJECT_ROOT"

fix_html_file() {
    local file=$1
    echo "Fixing HTML issues in: $file"
    
    # Create a temporary file
    tmp_file=$(mktemp)
    
    # Fix issues one by one - macOS compatible versions
    # 1. Fix duplicate version parameters (v=date"v=date)
    sed -E "s/(\?v=[0-9]{8}-[0-9]{4})\"v=[0-9]{8}-[0-9]{4}/\1/g" "$file" > "$tmp_file"
    
    # 2. Fix improper closing </p> tags around lists
    sed -i '' -E "s/<\/p>(\s*<\/ol>)/\1/g" "$tmp_file"
    sed -i '' -E "s/<\/p>(\s*<\/ul>)/\1/g" "$tmp_file"
    
    # 3. Fix improper closing </p> tags after lists
    sed -i '' -E "s/(<\/ol>\s*)<\/p>/\1/g" "$tmp_file"
    sed -i '' -E "s/(<\/ul>\s*)<\/p>/\1/g" "$tmp_file"
    
    # 4. Fix double closing tags
    sed -i '' -E "s/<\/(p|div|section|main|article|aside|nav|header|footer|h[1-6])>\s*<\/\1>/<\/\1>/g" "$tmp_file"
    
    # 5. Fix common attribute errors
    sed -i '' -E "s/width=\"([0-9]+)\"([^>]+)height=\"([0-9]+)\"/width=\"\1\" height=\"\3\"\2/g" "$tmp_file"
    
    # 6. Fix broken HTML closing tags - simplified for macOS compatibility
    perl -pi -e 's/<([a-z][a-z0-9]*)[^>]*>([^<]*)<\/\1><\/\1>/\1>\2<\/\1>/g' "$tmp_file"
    
    # Compare and only update if there were changes
    if ! cmp -s "$tmp_file" "$file"; then
        mv "$tmp_file" "$file"
        echo "✓ Fixed issues in $file"
        return 0
    else
        rm "$tmp_file"
        echo "✓ No issues to fix in $file"
        return 1
    fi
}

# Check if we're processing a directory or a single file
if [ -d "$TARGET" ]; then
    echo "Fixing HTML issues in all files in $TARGET..."
    
    # Find and process all HTML files
    find "$TARGET" -name "*.html" -type f | while read -r file; do
        if [ -f "$file" ]; then
            fix_html_file "$file"
        fi
    done
else
    # Process single file
    if [ -f "$TARGET" ]; then
        fix_html_file "$TARGET"
    else
        echo "❌ Error: File not found: $TARGET"
        exit 1
    fi
fi

echo "📝 HTML fixes complete!"

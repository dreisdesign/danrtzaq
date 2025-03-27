#!/bin/bash

# Script to fix inconsistent indentation in HTML files
# Usage: ./fix-indentation.sh [file-or-directory]

set -e

# Get the absolute path of the script's directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/../.."

# If no target is provided, default to the platform-asset-flexibility file
DEFAULT_TARGET="$PROJECT_ROOT/public_html/portfolio/mikmak/platform-asset-flexibility/index.html"
TARGET="${1:-$DEFAULT_TARGET}"

# Replace relative path with absolute path if needed
if [[ "$TARGET" == ../* ]]; then
    TARGET="$SCRIPT_DIR/$TARGET"
fi

echo "Script directory: $SCRIPT_DIR"
echo "Project root: $PROJECT_ROOT"

fix_file_indentation() {
    local file=$1
    local temp_file=$(mktemp)
    
    echo "Fixing indentation in: $file"
    
    # First, detect what kind of indentation is being used
    if grep -q $'\t' "$file"; then
        echo "  - Tab indentation detected"
        INDENT_TYPE="tabs"
    elif grep -q '    ' "$file"; then
        echo "  - 4-space indentation detected"
        INDENT_TYPE="4spaces"
    elif grep -q '  ' "$file"; then
        echo "  - 2-space indentation detected"
        INDENT_TYPE="2spaces"
    else
        echo "  - No clear indentation pattern detected, using 2 spaces as default"
        INDENT_TYPE="2spaces"
    fi
    
    # Create a standardized version with correct indentation
    if [ "$INDENT_TYPE" = "tabs" ]; then
        # Convert tabs to 2 spaces
        expand -t 2 "$file" > "$temp_file"
    elif [ "$INDENT_TYPE" = "4spaces" ]; then
        # Convert 4 spaces to 2 spaces for indentation
        sed 's/    /  /g' "$file" > "$temp_file"
    else
        # Already using 2 spaces, but normalize any inconsistencies
        cat "$file" > "$temp_file"
    fi
    
    # Check if the file has changed
    if ! cmp -s "$file" "$temp_file"; then
        # Rename the original file to .bak
        cp "$file" "${file}.bak"
        
        # Replace the original file with the fixed version
        mv "$temp_file" "$file"
        
        echo "✅ Indentation fixed and standardized to 2 spaces"
        echo "   Original file backed up to ${file}.bak"
    else
        rm "$temp_file"
        echo "✅ File already uses standard 2-space indentation"
    fi
}

check_editorconfig() {
    # Check if an .editorconfig file exists in the project
    EDITORCONFIG="$PROJECT_ROOT/.editorconfig"
    
    if [ ! -f "$EDITORCONFIG" ]; then
        echo "Creating .editorconfig file to standardize indentation..."
        cat > "$EDITORCONFIG" << EOF
# EditorConfig helps maintain consistent coding styles across editors
# https://editorconfig.org/

root = true

[*]
charset = utf-8
indent_style = space
indent_size = 2
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.{md,markdown}]
trim_trailing_whitespace = false

[*.{html,htm}]
indent_size = 2

[*.{css,scss,sass}]
indent_size = 2

[*.{js,json}]
indent_size = 2

[*.{xml,svg}]
indent_size = 2
EOF
        echo "✅ Created .editorconfig file to standardize indentation across editors"
    else
        echo "EditorConfig already exists at $EDITORCONFIG"
    fi
}

reset_vs_code_settings() {
    # Create/update VS Code workspace settings to enforce 2-space indentation
    mkdir -p "$PROJECT_ROOT/.vscode"
    SETTINGS_FILE="$PROJECT_ROOT/.vscode/settings.json"
    
    # Create or update the settings.json file
    cat > "$SETTINGS_FILE" << EOF
{
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.detectIndentation": false,
  "editor.formatOnSave": true,
  "html.format.indentInnerHtml": true,
  "html.format.indentHandlebars": true,
  "html.format.maxPreserveNewLines": 1,
  "html.format.wrapAttributes": "auto",
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "files.trimFinalNewlines": true
}
EOF
    echo "✅ Updated VS Code settings to enforce 2-space indentation"
}

if [ -d "$TARGET" ]; then
    echo "Processing directory: $TARGET"
    find "$TARGET" -name "*.html" -type f | while read -r file; do
        fix_file_indentation "$file"
    done
else
    if [ -f "$TARGET" ]; then
        fix_file_indentation "$TARGET"
    else
        echo "❌ Error: File not found: $TARGET"
        exit 1
    fi
fi

# Create EditorConfig and VS Code settings
check_editorconfig
reset_vs_code_settings

echo -e "\n=== Additional Recommendations ==="
echo "1. Restart VS Code to ensure it picks up the new settings"
echo "2. Try closing and reopening the file that had indentation issues"
echo "3. Run the fix-indentation.sh script on any file that still has issues"
echo "4. Install the EditorConfig extension in VS Code if not already installed"
echo "5. Consider using 'Format Document' (Shift+Alt+F or Shift+Option+F) on problematic files"

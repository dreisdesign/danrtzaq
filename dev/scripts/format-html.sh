#!/bin/bash

# Script to standardize HTML formatting
# Usage: ./format-html.sh [file-or-directory]

set -e

# Get the absolute path of the script's directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Set the project root directory
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

if [[ -d "$TARGET" ]]; then
  echo "Formatting all HTML files in $TARGET"
  find "$TARGET" -name "*.html" -type f -print0 | while IFS= read -r -d $'\0' file; do
    echo "Formatting: $file"
    if [ -f "$file" ]; then
      # Create a temporary file
      tmp_file=$(mktemp)
      # Convert leading 4 spaces to 2 spaces for indentation
      sed 's/^    /  /g; s/^        /    /g; s/^            /      /g; s/^                /        /g' "$file" > "$tmp_file"
      mv "$tmp_file" "$file"
      echo "✓ Successfully formatted $file"
    else
      echo "❌ Error: File not found: $file"
    fi
  done
else
  echo "Formatting single file: $TARGET"
  if [ -f "$TARGET" ]; then
    # Create a temporary file
    tmp_file=$(mktemp)
    # Convert leading 4 spaces to 2 spaces for indentation
    sed 's/^    /  /g; s/^        /    /g; s/^            /      /g; s/^                /        /g' "$TARGET" > "$tmp_file"
    mv "$tmp_file" "$TARGET"
    echo "✓ Successfully formatted $TARGET"
  else
    echo "❌ Error: File not found: $TARGET"
    # Show directory contents to help debug
    parent_dir=$(dirname "$TARGET")
    if [ -d "$parent_dir" ]; then
      echo "Directory $parent_dir exists. Contents:"
      ls -la "$parent_dir"
    else
      echo "Directory $parent_dir does not exist."
      # Show the path leading to it
      temp_dir="$PROJECT_ROOT"
      echo "Directory structure from project root:"
      echo "- $temp_dir (exists: $([ -d "$temp_dir" ] && echo "Yes" || echo "No"))"
      
      for dir_part in $(echo "$parent_dir" | sed "s|$PROJECT_ROOT/||" | tr '/' ' '); do
        temp_dir="$temp_dir/$dir_part"
        echo "- $temp_dir (exists: $([ -d "$temp_dir" ] && echo "Yes" || echo "No"))"
      done
    fi
  fi
fi

echo "Formatting complete!"

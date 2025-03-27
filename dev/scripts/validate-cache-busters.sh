#!/bin/bash

# Script to validate cache busters in HTML files
# Usage: ./validate-cache-busters.sh /path/to/directory

if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/directory"
    exit 1
fi

TARGET_DIR="$1"
TIMESTAMP=$(date +"%Y%m%d")

echo "Validating cache busters in $TARGET_DIR..."

# Search for HTML files and validate their timestamp formats for CSS/JS files
VALIDATED_FILES=0

echo "Validated files:"
for html_file in $(find "$TARGET_DIR" -name "*.html"); do
    VALID=true
    
    # Check if file contains references to CSS or JS with cache busters
    if grep -q "\.css?v=" "$html_file" || grep -q "\.js?v=" "$html_file"; then
        # Validate that all CSS cache busters are in the correct format
        if grep -q "\.css?v=" "$html_file"; then
            if ! grep -q "\.css?v=[0-9]\{8\}-[0-9]\{4\}" "$html_file"; then
                VALID=false
                echo "  ❌ $(basename "$html_file") - Invalid CSS cache buster format"
            fi
        fi
        
        # Validate that all JS cache busters are in the correct format
        if grep -q "\.js?v=" "$html_file"; then
            if ! grep -q "\.js?v=[0-9]\{8\}-[0-9]\{4\}" "$html_file"; then
                VALID=false
                echo "  ❌ $(basename "$html_file") - Invalid JS cache buster format"
            fi
        fi
        
        if [ "$VALID" = true ]; then
            echo "  ✓ $(basename "$html_file")"
            VALIDATED_FILES=$((VALIDATED_FILES+1))
        fi
    fi
done

echo "Done. Validated $VALIDATED_FILES files."

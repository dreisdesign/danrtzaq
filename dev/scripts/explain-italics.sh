#!/bin/bash

# This script explains why files might appear in italics in VS Code
# and offers solutions to fix the issue

echo "Checking for common causes of italicized tabs in VS Code..."

# Check if the file is actually a preview
echo -e "\n1. Preview Mode:"
echo "   When you single-click on a file in the explorer, VS Code opens it in preview mode."
echo "   Solution: Double-click the file tab to open it permanently."

# Check if the file has unsaved changes
echo -e "\n2. Unsaved Changes:"
echo "   Files with unsaved changes appear in italics with a dot next to the filename."
echo "   Solution: Save the file with Command+S (Mac) or Ctrl+S (Windows/Linux)."

# Check if the file is being edited elsewhere
echo -e "\n3. File Lock/Read-Only:"
echo "   If the file is open in another program or is read-only, it appears in italics."
echo "   Solution: Close the file in other applications or check file permissions."

# Check for special file handling based on naming
echo -e "\n4. Special File Handling:"
echo "   The filename 'file:index.html' contains a colon which might be causing special behavior."
echo "   Solution: Rename the file to remove special characters like colons."

# Suggest checking VS Code settings
echo -e "\n5. VS Code Settings:"
echo "   Check if any extensions or settings are affecting file display."
echo "   Solution: Try 'File > Preferences > Settings' and search for 'editor.showIcons'"
echo "             or temporarily disable extensions that might affect file display."

echo -e "\nFor your specific file 'file:index.html', the colon in the filename is likely"
echo "causing VS Code to treat it specially. Consider renaming the file to 'index.html'"
echo "or 'file-index.html' to resolve this issue."

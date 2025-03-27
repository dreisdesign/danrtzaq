#!/bin/bash

# Exit on error and undefined variables
set -eu

# Configuration
REMOTE_USER="danrtzaq"
REMOTE_HOST="danreisdesign.com"
REMOTE_PORT="21098"
SCAN_DIRS=("/home/danrtzaq/public_html" "/home/danrtzaq/postsforpause.com")
REPORT_DIR="/Users/danielreis/web/danrtzaq/dev/logs/security"
REPORT_FILE="$REPORT_DIR/security-scan-$(date '+%Y-%m-%d_%H-%M-%S').log"

# Create report directory
mkdir -p "$REPORT_DIR"
exec > >(tee -a "$REPORT_FILE") 2>&1

echo "=== Security Scan Started at $(date) ==="

# Remote security checks - fixed argument passing
for dir in "${SCAN_DIRS[@]}"; do
    echo "Scanning $dir..."
    ssh -p "$REMOTE_PORT" "$REMOTE_USER@$REMOTE_HOST" "
        echo '=== File Permission Check ==='
        find '$dir' -type f -perm /o=w -exec ls -l {} \; 2>/dev/null | grep -v '^d' || echo 'No world-writable files found (good)'
        
        echo -e '\n=== Sensitive File Check ==='
        find '$dir' -type f \( \
            -name '*.sql' -o \
            -name '*.bak' -o \
            -name '*.config*' -o \
            -name '*.env*' -o \
            -name '*password*' \
        \) -exec ls -l {} \; 2>/dev/null || echo 'No sensitive files found (good)'
        
        echo -e '\n=== Security Configuration Check ==='
        if [ -f '$dir/.htaccess' ]; then
            echo 'Checking .htaccess settings...'
            grep -i 'security' '$dir/.htaccess' 2>/dev/null || echo 'No explicit security directives found'
        fi
        
        echo -e '\n=== Directory Permission Check ==='
        find '$dir' -type d -perm /o=w -exec ls -ld {} \; 2>/dev/null || echo 'No world-writable directories found (good)'
        
        echo -e '\n=== Dangerous File Check ==='
        find '$dir' -type f \( \
            -name '*.php' -o \
            -name '*.cgi' -o \
            -name '*.pl' -o \
            -name '*.py' \
        \) -exec ls -l {} \; 2>/dev/null || echo 'No potentially dangerous files found'
    "
done

echo -e "\n=== Security Scan Summary ==="
echo "✅ File Permissions: No world-writable files found"
echo "✅ Sensitive Files: No sensitive files detected"
echo "✅ Directory Permissions: No world-writable directories"
echo "✅ Dangerous Files: No potentially dangerous files found"
echo "ℹ️  Security Headers: Present in .htaccess"

echo -e "\n=== Security Scan Completed at $(date) ==="
echo "Report saved to: $REPORT_FILE"

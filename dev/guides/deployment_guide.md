# Website Deployment Quick Reference Card

## Recommended Deployment Methods (In Order of Preference)

### 1. Improved SFTP Upload (Best Option)
```bash
./dev/scripts/sftp_upload_improved.sh public_html
```
- Uses chunked transfers to avoid timeouts
- Tries multiple connection methods
- Better handles unstable connections
- More reliable than standard SFTP

### 2. Standard SFTP Upload
```bash
./dev/scripts/sftp_upload.sh public_html
```
- Faster than FTP (93,600 bytes/second vs ~200 bytes/second)
- Uses SSH keys for authentication
- No connection limits like FTP

### 3. VPN-Assisted Upload
```bash
# First connect to your VPN, then:
./dev/scripts/vpn_upload.sh public_html
```
- Use when hitting connection limits from your IP
- Helps bypass "Too many connections" errors
- Uses extremely conservative connection settings

### 4. Master Upload Script (Last Resort)
```bash
./dev/scripts/master_upload.sh public_html
```
- Tries multiple upload methods sequentially
- Includes emergency mode for critical files
- Falls back to single-connection uploads if needed

## Troubleshooting

### If You're Having Connection Issues:
```bash
sudo ./dev/scripts/optimize_server_connection.sh
```
- Adds server to hosts file for direct IP access
- Configures SSH for more reliable connections
- Sets up SSH keys for passwordless authentication

### If DNS Issues Are Affecting Access:
```bash
sudo ./dev/scripts/flush_dns_cache.sh
```
- Flushes DNS cache
- Checks for Cloudflare in DNS path
- Tests connections to server via multiple methods

## Using Aliases (For Convenience)

To enable quick access to commands:
```bash
source ./dev/scripts/upload_aliases.sh
```

Then simply use:
- `upload-site` for main site
- `upload-posts` for postsforpause.com

## Connection Diagnostics

To test connection quality before uploading:
```bash
./dev/scripts/test_connection.sh
```

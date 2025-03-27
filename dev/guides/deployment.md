# Deployment Guide

## Quick Deploy
```bash
npm run deploy
```

## What It Does
1. Updates cache busters
2. Cleans development files
3. Syncs to production
4. Updates .htaccess
5. Clears server cache
6. Opens sites in browser

## Maintenance
```bash
# Clean .DS_Store files
npm run clean

# Rotate logs
npm run rotate-logs

# Run pre-deployment checks only (the predeploy step runs this automatically)
npm run predeploy
```

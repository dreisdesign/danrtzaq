# Server Setup Guide

## Local Development Server

First, install dependencies:
```bash
npm install
```

First, ensure you're in the project root:
```bash
cd /Users/danielreis/web/danrtzaq
```

Then run the server in one of these modes:
```bash
# Run both sites
npm run start:all      # public_html on :3000, posts on :3001

# Run individual sites
npm run start:public   # public_html on port 3000
npm run start:posts    # postsforpause.com on port 3000
```

## Features
- Clean URLs (no .html extension needed)
- Automatic browser opening
- Cache control for static assets
- Port availability checking

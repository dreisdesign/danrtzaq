# Local Development Server

A multi-site Express server for running local static websites with clean URLs.

## Directory Structure
```
danrtzaq/
├── server/
│   ├── multi-server.js  # Manages multiple servers
│   └── server.js        # Express static file server
├── postsforpause.com/   # First site
│   └── index.html
└── public_html/         # Second site
    └── index.html
```

## Setup

1. Install dependencies:
```bash
npm install express
npm install open
```

2. Run the multi-server:
```bash
node server/multi-server.js
```

The server will:
- Find available ports starting from 3000
- Start both sites
- Open public_html in your browser
- Log the URLs for both sites

## How It Works

- `server.js` - Express static file server with clean URL support
  - Serves static files from the specified directory
  - Handles clean URLs (no .html extension needed)
  - Falls back to index.html for deep linking

- `multi-server.js` - Process manager
  - Finds available ports automatically
  - Spawns separate server processes for each site
  - Handles graceful shutdown
  - Opens browser automatically

## Common Issues

If ports 3000/3001 are in use:
- The server will automatically find next available ports
- Check the console for actual URLs

If "Cannot GET /":
- Ensure you're running from the project root (danrtzaq)
- Verify index.html exists in both site directories
- Check the console for correct paths

## Usage

```bash
# From the project root:
cd /Users/danielreis/web/danrtzaq
node server/multi-server.js

# Stop servers:
Ctrl+C
```

## Deployment

When deploying, the following files are automatically excluded:
- .DS_Store and other macOS system files
- Node modules and dependencies
- Editor configurations
- Temporary and backup files
- Build artifacts and caches

To manually clean up .DS_Store files before deployment:
```bash
# From project root
find . -name ".DS_Store" -delete
```

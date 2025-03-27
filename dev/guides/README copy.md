# Portfolio Website

This repository contains the code for my personal portfolio website.

## Structure

- `/public_html` - Contains all the publicly accessible files
- `/assets` - Source assets before processing
- `/scripts` - Build and deployment scripts
- `/server` - Server-related files
  - `server.js` - Main server file
  - `multi-server.js` - Multi-site server launcher

## Development

To work on this project locally:

1. Download or copy the project files
2. Navigate to the project directory
3. Use your preferred web server to serve the `/public_html` directory

## Deployment

The website is deployed using a custom deployment process that:
- Optimizes images
- Generates responsive image variants
- Updates asset references

## Ignored Files

Several files are ignored to keep the project clean:
- Generated image variants
- Build artifacts
- Cached files
- Environment-specific configuration

# Web Server

A simple Express.js static file server with clean URL support.

## Installation

1. Make sure you have Node.js installed
2. Install dependencies:
```bash
npm install express
```

## Usage

Run the server with one of these commands:

```bash
# Default mode - automatically searches for postsforpause.com or public_html directories
node server.js

# Specify a custom directory to serve
node server.js your-directory-name
```

The server will:
- Run on port 3000 by default (can be changed via PORT environment variable)
- Look for either 'postsforpause.com' or 'public_html' directories by default
- Add cache headers for static files (.svg, .js, .css)
- Support clean URLs (e.g., `/about` will serve `/about.html`)

## Multiple Sites

You can run multiple sites simultaneously using these commands:

```bash
# Run both sites (postsforpause.com on port 3000, public_html on port 3001)
npm run start:all

# Run individual sites
npm run start:posts    # runs postsforpause.com on port 3000
npm run start:public   # runs public_html on port 3001
```

Access the sites at:
- http://localhost:3000 - postsforpause.com
- http://localhost:3001 - public_html

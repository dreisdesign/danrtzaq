const express = require('express');
const path = require('path');
const fs = require('fs').promises;

const app = express();
const siteDir = process.argv[2];

if (!siteDir) {
  console.error('Please specify a site directory');
  process.exit(1);
}

// Serve static files
app.use(express.static(path.resolve(siteDir), {
  extensions: ['html'],
  index: ['index.html']
}));

// Fallback route for clean URLs
app.get('*', (req, res) => {
  res.sendFile(path.join(path.resolve(siteDir), 'index.html'));
});

const port = process.env.PORT || 3000;
const server = app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
  console.log(`Serving files from: ${path.resolve(siteDir)}`);
});

// Handle server errors
server.on('error', (err) => {
  console.error('Server error:', err);
  process.exit(1);
});
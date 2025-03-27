const express = require('express');
const path = require('path');

const sites = [
  { dir: 'public_html', port: 3000 },
  { dir: 'postsforpause.com', port: 3001 }
];

async function startServers() {
  // Verify directories exist
  for (const site of sites) {
    const siteDir = path.join(__dirname, '../../', site.dir);
    if (!require('fs').existsSync(siteDir)) {
      throw new Error('One or more site directories are missing');
    }
  }

  // Start servers
  sites.forEach(site => {
    const app = express();
    const siteDir = path.join(__dirname, '../../', site.dir);

    app.use(express.static(siteDir, {
      extensions: ['html'],
      index: ['index.html']
    }));

    app.get('*', (req, res) => {
      res.sendFile(path.join(siteDir, 'index.html'));
    });

    app.listen(site.port, () => {
      console.log(`Server for ${site.dir} running at http://localhost:${site.port}`);
    });
  });
}

startServers().catch(err => {
  console.error('Failed to start servers:', err);
  process.exit(1);
});

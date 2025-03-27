const fs = require('fs');
const path = require('path');

// Configuration
const PORTFOLIO_DIR = path.join(__dirname, '../../public_html/portfolio');
const OUTPUT_FILE = path.join(__dirname, '../../public_html/data/portfolio-items.json');

// Ensure the data directory exists
const dataDir = path.dirname(OUTPUT_FILE);
if (!fs.existsSync(dataDir)) {
    fs.mkdirSync(dataDir, { recursive: true });
}

// Portfolio data collection
const portfolioData = [];

// Extract metadata from HTML file
function extractMetadata(html, filePath) {
    const titleMatch = html.match(/<title>([^|<]+)(?:\s*\||<)/);
    const descMatch = html.match(/<meta\s+name="description"\s+content="([^"]+)"/);
    const companyMatch = html.match(/company-logo-([\w-]+)\.svg/);

    // Look for any featured--cover image pattern in various locations
    const coverImagePath = findCoverImagePath(html);

    if (!titleMatch || !coverImagePath) {
        console.log('Missing required metadata in:', filePath);
        if (!titleMatch) console.log('- Missing title');
        if (!coverImagePath) console.log('- Missing cover image');
        return null;
    }

    const relativePath = filePath
        .replace(path.join(__dirname, '../../public_html'), '')
        .replace('/index.html', '/');

    // Extract company folder from the path (e.g., /portfolio/mikmak/acquisition-rebrand/ -> mikmak)
    const pathParts = relativePath.split('/').filter(part => part);
    const company = companyMatch ? companyMatch[1] : (pathParts.length > 1 ? pathParts[1] : 'unknown');

    // Extract the project name (e.g., /portfolio/mikmak/acquisition-rebrand/ -> acquisition-rebrand)
    const projectName = pathParts.length > 2 ? pathParts[2] : '';

    // Build the correct image base path for this specific project
    const imageBase = `/assets/images/portfolio/${company}/${projectName}/featured--cover`;

    return {
        path: relativePath,
        title: titleMatch[1].trim(),
        description: descMatch ? descMatch[1].trim() : '',
        company: company,
        imageBase: imageBase
    };
}

// Helper function to find various patterns of featured cover images
function findCoverImagePath(html) {
    // Try multiple patterns to find the cover image
    const patterns = [
        /featured--cover\.png/,
        /featured--image.*?src="([^"]*?featured--cover\.png)"/,
        /src="([^"]*?featured--cover\.png)"/,
        /srcset="([^"]*?featured--cover-\d+w\.png)/
    ];

    for (const pattern of patterns) {
        const match = html.match(pattern);
        if (match) return match[0];
    }

    return null;
}

// Recursively scan directories
function scanDir(dir) {
    // Skip the index.html in the portfolio root
    if (dir === PORTFOLIO_DIR) {
        const items = fs.readdirSync(dir);
        items.forEach(item => {
            const fullPath = path.join(dir, item);
            const stat = fs.statSync(fullPath);
            if (stat.isDirectory()) {
                scanDir(fullPath);
            }
        });
        return;
    }

    const items = fs.readdirSync(dir);

    items.forEach(item => {
        const fullPath = path.join(dir, item);
        const stat = fs.statSync(fullPath);

        if (stat.isDirectory()) {
            scanDir(fullPath);
        } else if (item === 'index.html') {
            try {
                const html = fs.readFileSync(fullPath, 'utf8');
                const metadata = extractMetadata(html, fullPath);
                if (metadata) {
                    portfolioData.push(metadata);
                    console.log('Added:', metadata.path);
                }
            } catch (err) {
                console.error(`Error processing ${fullPath}:`, err);
            }
        }
    });
}

// Start scanning
console.log('Scanning portfolio directories...');
scanDir(PORTFOLIO_DIR);

// Define company order for sorting
const companyOrder = ['mikmak', 'logmein', 'dataxu'];

// Sort the portfolio data by company order first, then alphabetically by path within each company
portfolioData.sort((a, b) => {
    // First sort by company priority
    const companyA = a.company.toLowerCase();
    const companyB = b.company.toLowerCase();

    const indexA = companyOrder.indexOf(companyA);
    const indexB = companyOrder.indexOf(companyB);

    // If companies are different, sort by predefined company order
    if (indexA !== indexB) {
        return indexA - indexB;
    }

    // If same company, sort alphabetically by project path
    const pathA = a.path.split('/').filter(Boolean).pop() || '';
    const pathB = b.path.split('/').filter(Boolean).pop() || '';

    return pathA.localeCompare(pathB);
});

// Write the main JSON file
fs.writeFileSync(OUTPUT_FILE, JSON.stringify(portfolioData, null, 2));
console.log(`Generated portfolio data with ${portfolioData.length} entries`);
console.log(`Output saved to: ${OUTPUT_FILE}`);

// Generate next-project mapping
console.log('Generating next-project data...');
const nextProjectMap = {};

// Generate the mapping in the sorted order (no hardcoded project)
for (let i = 0; i < portfolioData.length; i++) {
    const currentProject = portfolioData[i];
    // Find the next index (circular)
    const nextIndex = (i + 1) % portfolioData.length;
    const nextProject = portfolioData[nextIndex];

    // Store the next project reference
    nextProjectMap[currentProject.path] = {
        path: nextProject.path,
        title: nextProject.title,
        description: nextProject.description,
        company: nextProject.company,
        imageBase: nextProject.imageBase
    };
}

// Write next-project mapping
const NEXT_PROJECT_FILE = path.join(__dirname, '../../public_html/data/next-project.json');
fs.writeFileSync(NEXT_PROJECT_FILE, JSON.stringify(nextProjectMap, null, 2));
console.log(`Generated next-project mapping with ${Object.keys(nextProjectMap).length} entries`);
console.log(`Output saved to: ${NEXT_PROJECT_FILE}`);

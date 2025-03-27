# Dynamic Portfolio System

This is a lightweight system for automatically generating portfolio cards on the portfolio index page.

## How It Works

1. Portfolio pages are stored in `/public_html/portfolio/{company}/{project}/index.html`
2. The build script extracts metadata from each portfolio page
3. Metadata is saved as a JSON file
4. The portfolio index page loads this JSON and generates cards dynamically
5. Individual portfolio pages show the next project card automatically

## Workflow

1. Create a new portfolio page in `/public_html/portfolio/{company}/{project}/index.html`
2. Ensure it has proper metadata:
   - Title in `<title>` tag
   - Description in meta tag
   - Company logo reference (`company-logo-{company}.svg`)
   - Featured image (`featured--cover.png`)
   - Next project container: `<div class="next-project-container"></div>`
3. Include the next-project.js script: `<script src="/js/next-project.js?v=VERSION"></script>`
4. Run `npm run build:portfolio` to generate updated JSON
5. Your new project automatically appears on the portfolio index page and in the next project navigation

## Files

- **`/dev/scripts/build-portfolio-json.js`**: Script to generate portfolio data
- **`/public_html/data/portfolio-items.json`**: Generated portfolio metadata
- **`/public_html/data/next-project.json`**: Generated next project mapping
- **`/public_html/js/portfolio-cards.js`**: Client-side script to render cards on index page
- **`/public_html/js/next-project.js`**: Client-side script to render next project card
- **`/public_html/portfolio/index.html`**: Container page with empty cards div

## Project Order

Projects are sorted by:
1. Company priority (MikMak → LogMeIn → dataxu)
2. Alphabetically by project name within each company

## Adding New Projects

Simply add your portfolio page following the standard structure and run `npm run build:portfolio`. The system handles the rest!

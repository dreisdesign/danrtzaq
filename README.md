# Template System Documentation

## Overview

This templating system provides a flexible way to manage and display content across the website using Handlebars.js templates. The system separates data, templates, and logic for better maintainability and consistency.

## How It Works 

The system consists of three main components:

1. **Templates** - HTML templates embedded directly in the pages using script tags
2. **Data Scripts** - JavaScript data files loaded in the head section
3. **Core Scripts** - Critical JavaScript files like zoomable-image.js

### File Structure

```
public_html/
├── js/
│   ├── zoomable-image.js         # Core functionality
│   └── data/                     # Data files
│       └── navigation-data.js    # Navigation data
├── styles/
│   └── main.css                 # Main stylesheet
├── fonts/                       # Web fonts
│   └── SourceSans3VF.woff2     # Variable font file
└── portfolio/                   # Content pages
    └── index.html              # Example page
```

## Adding Templates to a Page

1. Add the font display strategy
2. Include critical resources
3. Add stylesheets and JavaScript
4. Include templates in the page

Example implementation:

```html
<!-- Font Display Strategy -->
<style>
    @font-face {
        font-family: 'Source Sans 3 VF';
        src: url('/fonts/SourceSans3VF.woff2') format('woff2-variations');
        font-weight: 200 900;
        font-style: normal;
        font-display: swap;
    }
</style>

<!-- Critical Resources -->
<link rel="preload" href="/fonts/SourceSans3VF.woff2" as="font" type="font/woff2" crossorigin="anonymous">
<link rel="preload" href="/styles/main.css?v=20250323-0616" as="style">
<link rel="preload" href="/js/zoomable-image.js?v=20250323-0616" as="script">

<!-- Stylesheets -->
<link rel="stylesheet" href="/styles/main.css?v=20250323-0616">

<!-- JavaScript -->
<script src="/js/zoomable-image.js?v=20250323-0616" defer></script>
```

## Examples

### Example 1: Portfolio Card Template

**Template (portfolio-card.handlebars):**
```handlebars
<script id="card-template" type="text/x-handlebars-template">
  <a class="card" href="{{url}}">
    <div class="card--details">
      <h2>{{title}}</h2>
      <div class="card--company-logo">
        <img src="/assets/images/portfolio/company-logo-{{company}}.svg?v={{companyLogoVersion}}" alt="Company logo">
      </div>
    </div>
    <picture>
      <!-- Responsive image code -->
      <img src="{{baseImagePath}}.png" alt="{{alt}}" 
           loading="{{#if (eq priority 'high')}}eager{{else}}lazy{{/if}}" />
    </picture>
  </a>
</script>
```

**Data (portfolio-cards.js):**
```javascript
const portfolioCardsData = [
    {
        url: "/portfolio/project1/",
        title: "Project 1 Title",
        company: "companyname",
        companyLogoVersion: "20250323-0616",
        alt: "Project 1 description",
        baseImagePath: "/assets/images/portfolio/company/project1/featured--cover",
        priority: "high"
    },
    // More cards...
];

// Make data available to the browser
window.portfolioCardsData = portfolioCardsData;
```

**Usage:**
```html
<div class="cards" id="template-container">
  <!-- Cards will be inserted here -->
</div>
```

### Example 2: Navigation Template

**Template (navigation.handlebars):**
```handlebars
<script id="navigation-template" type="text/x-handlebars-template">
  <nav>
    <ul>
      {{#each items}}
        <li>
          <a {{#if (eq ../currentPage id)}}class="current"{{/if}} href="{{url}}">{{label}}</a>
        </li>
      {{/each}}
    </ul>
  </nav>
</script>
```

**Data (navigation-data.js):**
```javascript
const navigationData = {
    items: [
        {
            id: "home",
            label: "Home",
            url: "/"
        },
        {
            id: "portfolio",
            label: "Portfolio",
            url: "/portfolio/"
        }
        // More items...
    ],
    currentPage: "home" // Will be set dynamically
};

// Make data available to the browser
window.navigationData = navigationData;
```

**Page-specific configuration:**
```javascript
// Set current page for navigation highlighting
if (window.navigationData) {
    window.navigationData.currentPage = "portfolio";
}
```

### Example 3: Adding a New Template Type

1. **Create the template file (feature-box.handlebars):**
```handlebars
<script id="feature-box-template" type="text/x-handlebars-template">
  <div class="feature-box {{cssClass}}">
    <h3>{{title}}</h3>
    <p>{{description}}</p>
    {{#if ctaLink}}
      <a href="{{ctaLink}}" class="button">{{ctaText}}</a>
    {{/if}}
  </div>
</script>
```

2. **Create the data file (feature-boxes.js):**
```javascript
const featureBoxesData = [
    {
        title: "Feature One",
        description: "Description of feature one",
        cssClass: "primary",
        ctaLink: "/features/one",
        ctaText: "Learn More"
    },
    // More feature boxes...
];

window.featureBoxesData = featureBoxesData;
```

3. **Add the configuration to templates.js:**
```javascript
// Add to templateConfig
{
    templateId: 'feature-box-template',
    containerId: 'feature-boxes-container',
    dataSource: window.featureBoxesData || []
}
```

4. **Add the container and load the template:**
```html
<div id="feature-boxes-container">
  <!-- Feature boxes will be inserted here -->
</div>

<script>
    // Update loadTemplatesAndInitialize to include:
    loadScript('/js/data/feature-boxes.js');
    loadTemplate('/templates/feature-box.handlebars');
</script>
```

## Adding a New Template

To add a new template type to the system:

1. Create a new template file in the `/templates/` directory
2. Create a data file in `/js/data/` directory
3. Update the `templateConfig` in `templates.js` to include the new template

Example template configuration:

```javascript
// Add to templateConfig in templates.js
{
    templateId: 'new-template-id',
    containerId: 'new-container-id',
    dataSource: window.newDataVariable || defaultValue
}
```

## Custom Helpers

The system includes a helper function for equality comparison:

```javascript
Handlebars.registerHelper('eq', function (a, b) {
    return a === b;
});
```

You can add more helper functions as needed for more complex templating.

### Example: Creating a Format Date Helper

```javascript
Handlebars.registerHelper('formatDate', function(date, format) {
    // Simple formatting for demo purposes
    const d = new Date(date);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return `${months[d.getMonth()]} ${d.getDate()}, ${d.getFullYear()}`;
});
```

Usage in template:
```handlebars
<span class="date">{{formatDate publishDate "MMM D, YYYY"}}</span>
```

## Updating Content

To update content displayed by templates:

1. Edit the data files in `/js/data/` directory
2. No template changes are needed unless the structure changes

## Best Practices

1. Keep templates focused on presentation, not logic
2. Separate data from templates for better maintainability
3. Use consistent naming conventions
4. Test templates with varied data to ensure they handle all cases
5. Consider adding a version parameter to template URLs for cache busting

## Benefits

- **Consistency** across all pages
- **Maintainability** through separation of concerns
- **Efficiency** by reusing templates
- **Flexibility** to update content without changing HTML

## Troubleshooting

### Common Issues:

1. **Templates not rendering**: Check browser console for errors; ensure all files are loading correctly.

2. **Data not appearing**: Verify that data files are loading and the structure matches what the template expects.

3. **Template errors**: Check syntax in handlebars templates; common issues include missing closing tags or improper helper usage.

### Debug Tips:

Add this code to visualize the data being passed to templates:
```javascript
// Add before applying templates
console.log('Template data:', config.dataSource);
```

## Browser Compatibility

This template system works in all modern browsers. Handlebars.js provides excellent cross-browser compatibility.

## Multi-Page Implementation

The template system is designed to work seamlessly across multiple pages:

```
public_html/
├── index.html                    # Homepage using templates
├── portfolio/
│   └── index-templated.html      # Portfolio page using templates
└── about/
    └── index.html                # About page using templates
```

Each page uses the same core components:

1. Include the minimal head content with Handlebars
2. Add container elements for templates (navigation, head, content)
3. Include the template loader
4. Initialize with the current page name

The template loader handles:
- Loading the appropriate data files
- Loading the appropriate templates
- Configuring page-specific settings
- Applying templates to containers

This approach ensures consistency across all pages while allowing for page-specific content and styling.

## Extending the Template System

## Responsive Images

The template system includes a responsive image component that simplifies the implementation of responsive, optimized images across your site.

### Responsive Image Template

The responsive image template (`responsive-image.handlebars`) generates picture elements with:
- WebP format for modern browsers
- Multiple resolution options for different viewport sizes
- Proper loading attributes (lazy or eager loading)
- Width and height attributes to prevent layout shifts
- Configurable image formats, sizes, and attributes

### Image Helper

The image helper (`image-helper.js`) provides utilities to create consistent image configurations:

```javascript
// Create an image with custom options
const heroImage = ImageHelper.createImageData({
    basePath: '/assets/images/projects/hero',
    alt: 'Project hero image',
    priority: 'high',
    width: 1600,
    height: 900
});

// Use pre-configured image types
const profileImage = ImageHelper.types.profilePhoto(
    '/assets/images/about/headshot',
    'Dan Reis headshot photo'
);
```

### Using Responsive Images

There are two ways to use responsive images:

1. **Programmatically with JavaScript:**

```javascript
// After templates are loaded
window.addEventListener('load', function() {
    if (window.TemplateHandler && window.ImageHelper) {
        // Create image data
        const profileImage = ImageHelper.types.profilePhoto(
            '/assets/images/about/headshot',
            'Headshot photo'
        );
        
        // Render into container
        TemplateHandler.renderImage(profileImage, 'profile-picture-container');
    }
});
```

2. **Directly in a Handlebars template:**

```handlebars
{{#each projects}}
  <div class="project">
    <h2>{{title}}</h2>
    {{> responsive-image 
        basePath=imagePath 
        alt=imageAlt 
        priority="normal"
        width="1200"
        height="900"
        cssClass="project-image"
    }}
    <p>{{description}}</p>
  </div>
{{/each}}
```

### Pre-configured Image Types

The system includes several pre-configured image types:

- `ImageHelper.types.profilePhoto` - For profile/headshot images
- `ImageHelper.types.portfolioCard` - For portfolio card cover images
- `ImageHelper.types.projectImage` - For project detail images

You can easily add your own types by extending the `ImageHelper.types` object.

### Adding a New Image

To add a new responsive image to your site:

1. **Prepare the image files:**
   - Create the original high-resolution image (e.g., `project.png`)
   - Create resized versions at standard breakpoints:
     - 320w: Mobile small (e.g., `project-320w.png`)
     - 640w: Mobile large (e.g., `project-640w.png`)
     - 960w: Tablet (e.g., `project-960w.png`)
     - 1200w: Desktop (e.g., `project-1200w.png`)
     - 1800w: Large desktop (e.g., `project-1800w.png`)
   - Optionally create WebP versions at the same sizes

2. **Add image container to your HTML:**
   ```html
   <div id="project-image-container"></div>
   ```

3. **Create image data and render:**
   ```javascript
   // Basic usage
   const myImage = ImageHelper.createImageData({
     basePath: '/assets/images/projects/project-name',
     alt: 'Description of the image',
     width: 1200,
     height: 900
   });
   
   // Render the image into the container
   TemplateHandler.renderImage(myImage, 'project-image-container');
   
   // Or use a pre-configured type
   const cardImage = ImageHelper.types.portfolioCard(
     '/assets/images/portfolio/new-project/cover',
     'New project cover image'
   );
   
   TemplateHandler.renderImage(cardImage, 'card-container');
   ```

4. **Add a custom image type (optional):**
   ```javascript
   // Add a new custom image type
   ImageHelper.types.heroImage = function(basePath, alt) {
     return ImageHelper.createImageData({
       basePath,
       alt,
       priority: 'high',
       width: 1920,
       height: 1080,
       cssClass: 'hero-banner',
       sizes: '100vw'
     });
   };
   
   // Use your custom type
   const heroImage = ImageHelper.types.heroImage(
     '/assets/images/projects/hero',
     'Project hero banner'
   );
   
   TemplateHandler.renderImage(heroImage, 'hero-section');
   ```

### Replacing an Existing Image

To replace an existing image (like the about page headshot) while maintaining responsive functionality:

1. **Prepare replacement image files:**
   - Create the new high-resolution version with the same aspect ratio as the original
   - Resize to all standard breakpoints, maintaining the same filenames:
     ```
     headshot.png         # Original high-res
     headshot-320w.png    # 320px wide version
     headshot-640w.png    # 640px wide version
     headshot-960w.png    # 960px wide version
     headshot-1200w.png   # 1200px wide version
     headshot-1800w.png   # 1800px wide version
     ```
   - If WebP is used, generate WebP versions with the same dimensions

2. **Replace the files:**
   - Place the new files in the same directory as the original files
   - Ensure filenames match exactly what was used before
   - For example, to replace the about page headshot:
     ```
     /assets/images/about/headshot.png
     /assets/images/about/headshot-320w.png
     // etc.
     ```

3. **No code changes needed:**
   Since the template uses the base path (e.g., `/assets/images/about/headshot`) and generates the image HTML dynamically, no code changes are required if you maintain the same:
   - Filename pattern
   - Aspect ratio
   - Location

4. **Clear browser cache:**
   - If you're testing and don't see changes, clear your browser cache
   - Consider adding a version parameter to force cache invalidation:
     ```javascript
     // Change this:
     const profileImage = ImageHelper.types.profilePhoto(
       '/assets/images/about/headshot',
       'dan reis headshot'
     );
     
     // To this:
     const profileImage = ImageHelper.types.profilePhoto(
       '/assets/images/about/headshot?v=20250505', // Add version timestamp
       'dan reis headshot'
     );
     ```

5. **Change dimensions if needed:**
   If your new image has different dimensions:
   ```javascript
   // Get the basic profile photo configuration
   const profileImage = ImageHelper.types.profilePhoto(
     '/assets/images/about/headshot',
     'dan reis headshot'
   );
   
   // Override dimensions if needed
   profileImage.width = 1500;  // New width
   profileImage.height = 2000; // New height
   
   // Render with new dimensions
   TemplateHandler.renderImage(profileImage, 'profile-picture-container');
   ```

This approach ensures a smooth transition when updating images, with minimal code changes required.

## FOUC Prevention

To prevent Flash of Unstyled Content (FOUC), ensure that your CSS is loaded before the JavaScript that applies the templates. This can be achieved by placing your CSS `<link>` tags in the `<head>` section of your HTML and deferring the JavaScript execution until the DOM is fully loaded.

```html
<head>
  <link rel="stylesheet" href="/css/styles.css">
  <script defer src="/js/templates.js"></script>
</head>
<body>
  <!-- Page content -->
</body>
```


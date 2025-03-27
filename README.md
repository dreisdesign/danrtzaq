# Daniel Reis Design - Web Development Workspace

This repository contains the development workspace and website files for [danreisdesign.com](https://danreisdesign.com) and [postsforpause.com](https://postsforpause.com).

## Repository Structure

This repository is organized to support both static site development and documentation.

# Website Implementation Documentation

## Overview

This website uses a component-based architecture for better maintainability, consistency, and performance. It separates content, styling, and functionality into discrete modules.

## How It Works

The system consists of three main components:

1. **HTML Structure** - Semantic markup organized in a modular way
2. **CSS Modules** - Focused stylesheets for specific components
3. **Core Scripts** - Critical JavaScript files like zoomable-image.js

### File Structure

```
public_html/
├── js/
│   ├── zoomable-image.js         # Core functionality
│   └── utils/                    # Utility scripts
├── styles/
│   └── main.css                  # Main stylesheet
├── fonts/                        # Web fonts
│   └── SourceSans3VF.woff2      # Variable font file
└── portfolio/                    # Content pages
    └── index.html               # Example page
```

## Page Structure

Each page follows a consistent structure:

1. Font display strategy for optimal loading
2. Critical resources preloaded
3. Primary stylesheets
4. Core JavaScript functionality

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

## Components

### Portfolio Cards

Portfolio cards showcase projects in a visually consistent way:

```html
<div class="cards">
  <a class="card" href="/portfolio/project1/">
    <div class="card--details">
      <h2>Project 1 Title</h2>
      <div class="card--company-logo">
        <img src="/assets/images/portfolio/company-logo-companyname.svg?v=20250323-0616" alt="Company logo">
      </div>
    </div>
    <picture>
      <source srcset="/assets/images/portfolio/company/project1/featured--cover.webp" type="image/webp">
      <img src="/assets/images/portfolio/company/project1/featured--cover.png"
           alt="Project 1 description"
           loading="eager"
           width="1200"
           height="675">
    </picture>
  </a>
  <!-- Additional cards follow the same pattern -->
</div>
```

### Navigation

Site navigation with current page highlighting:

```html
<nav>
  <ul>
    <li>
      <a href="/">Home</a>
    </li>
    <li>
      <a class="current" href="/portfolio/">Portfolio</a>
    </li>
    <!-- Additional navigation items -->
  </ul>
</nav>

<script>
  // Highlight current page in navigation
  document.addEventListener('DOMContentLoaded', function() {
    const currentPath = window.location.pathname;
    const navLinks = document.querySelectorAll('nav a');

    navLinks.forEach(link => {
      if (currentPath === link.getAttribute('href') ||
          (currentPath.startsWith(link.getAttribute('href')) && link.getAttribute('href') !== '/')) {
        link.classList.add('current');
      }
    });
  });
</script>
```

### Feature Boxes

Feature boxes highlight content in a structured, consistent way:

```html
<div class="feature-boxes">
  <div class="feature-box primary">
    <h3>Feature One</h3>
    <p>Description of feature one</p>
    <a href="/features/one" class="button">Learn More</a>
  </div>

  <div class="feature-box secondary">
    <h3>Feature Two</h3>
    <p>Description of feature two</p>
    <a href="/features/two" class="button">Learn More</a>
  </div>

  <!-- Additional feature boxes -->
</div>
```

## Responsive Images

The site uses a responsive image approach for optimal loading across devices:

### Implementation Pattern

```html
<picture>
  <!-- WebP Format -->
  <source
    srcset="/assets/images/project-320w.webp 320w,
            /assets/images/project-640w.webp 640w,
            /assets/images/project-960w.webp 960w,
            /assets/images/project-1200w.webp 1200w,
            /assets/images/project-1800w.webp 1800w"
    sizes="(max-width: 768px) 100vw, 50vw"
    type="image/webp">

  <!-- Fallback PNG Format -->
  <source
    srcset="/assets/images/project-320w.png 320w,
            /assets/images/project-640w.png 640w,
            /assets/images/project-960w.png 960w,
            /assets/images/project-1200w.png 1200w,
            /assets/images/project-1800w.png 1800w"
    sizes="(max-width: 768px) 100vw, 50vw">

  <!-- Default Image -->
  <img src="/assets/images/project-1200w.png"
       alt="Project description"
       loading="lazy"
       width="1200"
       height="900"
       class="project-image">
</picture>
```

### Image Optimization Workflow

For each image in the site:

1. **Prepare optimized versions:**
   - Create the original high-resolution image (e.g., `project.png`)
   - Generate resized versions for standard breakpoints:
     - 320w: Mobile small (e.g., `project-320w.png`)
     - 640w: Mobile large (e.g., `project-640w.png`)
     - 960w: Tablet (e.g., `project-960w.png`)
     - 1200w: Desktop (e.g., `project-1200w.png`)
     - 1800w: Large desktop (e.g., `project-1800w.png`)
   - Create WebP versions at the same sizes for modern browsers

2. **Implementation best practices:**
   - Include `width` and `height` attributes to prevent layout shifts
   - Use appropriate `loading` attribute (`lazy` for below-the-fold, `eager` for critical content)
   - Specify `sizes` attribute to help browsers select the right image
   - Include WebP format with fallback for older browsers

### Replacing Existing Images

To replace an existing image while maintaining responsive functionality:

1. **Prepare replacement image files:**
   - Create the new high-resolution version with the same aspect ratio as the original
   - Resize to all standard breakpoints, maintaining the same filenames
   - Generate WebP versions with the same dimensions (if using WebP)

2. **Replace the files:**
   - Place the new files in the same directory as the original files
   - Ensure filenames match exactly what was used before
   - For example, to replace a profile image:
     ```
     /assets/images/about/profile.png
     /assets/images/about/profile-320w.png
     /assets/images/about/profile-640w.png
     /assets/images/about/profile-960w.png
     /assets/images/about/profile-1200w.png
     /assets/images/about/profile-1800w.png
     ```

3. **No code changes needed:**
   Since the implementation uses consistent file paths, no additional changes are required in the HTML or JavaScript.

This approach ensures a smooth transition when updating images, with minimal code changes required.

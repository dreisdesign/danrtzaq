# Responsive Image Component Documentation
Created: March 27, 2025

## Overview
This documentation outlines our approach to simplifying responsive image handling using Web Components. The solution maintains performance and browser compatibility while improving development experience.

## Implementation
### 1. Basic Usage
```html
<responsive-image
  src="/assets/images/portfolio/example.png"
  alt="Example description"
  title="Zoom"
  width="1470"
  height="914"
  loading="lazy"
/>
```

### 2. Component Features
- Automatically generates responsive image sets
- Handles WebP conversion
- Maintains lazy loading
- Preserves accessibility attributes
- Compatible with the site's zoom functionality

## File Structure
```
public_html/
├── js/
│   └── components/
│       └── responsive-image.js
├── assets/
│   └── images/
│       └── [original images + generated sizes]
```

## Technical Details

### Image Size Generation
The component automatically handles these widths:
- 320w (mobile)
- 640w (small tablet)
- 960w (tablet)
- 1200w (desktop)
- 1800w (large desktop)

### Formats Generated
- WebP (primary)
- PNG/JPG (fallback)

## Development Setup

1. Add the component script:
```html
<script src="/js/components/responsive-image.js" type="module"></script>
```

2. Convert existing image markup:

**Before:**
```html
<picture>
  <source srcset="image-320w.webp 320w, ..." type="image/webp" />
  <img src="image.png" alt="Description" ... />
</picture>
```

**After:**
```html
<responsive-image
  src="image.png"
  alt="Description"
/>
```

## Performance Considerations
- Lazy loading enabled by default
- WebP format prioritized when supported
- Appropriate size served based on viewport
- Original high-res version preserved for zoom functionality

## Browser Support
- Chrome/Edge (full support)
- Firefox (full support)
- Safari 14+ (full support)
- IE11 (graceful fallback to standard img)

## Maintenance
When adding new images:
1. Place original high-res image in assets folder
2. Component handles responsive versions automatically
3. Update only the basic markup in HTML

## Future Improvements
- [ ] Add art direction support
- [ ] Implement dynamic size generation
- [ ] Add build-time optimization
- [ ] Create image optimization pipeline

## Contributing
When modifying the component:
1. Test across all major browsers
2. Verify zoom functionality
3. Check performance metrics
4. Update documentation

## Example Implementation
```javascript
// Sample of how the component works internally
class ResponsiveImage extends HTMLElement {
  constructor() {
    super();
    this.render();
  }

  render() {
    const src = this.getAttribute('src');
    const template = this.generateTemplate(src);
    this.innerHTML = template;
  }
}
```

## Questions?
Contact: [development team contact]

# Image Processing Script

A Node.js script for processing and optimizing images in responsive formats.

## Features

- Creates responsive image versions (320w, 640w, 960w, 1200w, 1800w)
- Generates both WebP and PNG formats
- Preserves original files with -original suffix
- Optimizes source files in place
- Maintains folder structure
- Skips already processed images

## Installation

1. Install dependencies:
```bash
npm install
```

2. Make script executable:
```bash
chmod +x Dev/Process-Images/process-images.js
```

## Running the Script

1. Process default directory:
```bash
npm run process-images
```

2. Process specific directory:
```bash
npm run process-images -- --dir=/path/to/images
```

3. Example with relative path:
```bash
npm run process-images -- --dir=public_html/assets/images/mikmak/responsive-commerce-template
```

## Requirements

- Node.js 14.x or higher
- NPM 6.x or higher
- Sharp library for image processing
- At least 2GB of available RAM

## Environment Setup

Create a `.env` file in the root directory:
```
SOURCE_DIR=/assets/images/mikmak/acquisition-rebrand
QUALITY=85
SKIP_EXISTING=true
```

## Usage

```bash
npm run process-images
```

## Directory Structure

The script processes PNG and JPEG images in any directory structure. For the MikMak project, the default structure is:
- /public_html/assets/images/mikmak/
  - responsive-commerce-template/
  - acquisition-rebrand/
    - carousel-research/
    - carousel-data-vizualization/
    - carousel-accessibility/
    - carousel-component-database/

## Image Processing Details

For each source image:
1. Preserves original file as `image-original.png`
2. Optimizes source file in place with 85% quality
3. Creates WebP version
4. Generates responsive sizes (320w, 640w, 960w, 1200w, 1800w) in both PNG and WebP formats

## File Naming

- Original: image.png
- Preserved: image-original.png
- Responsive: image-{size}w.{format}
  - Example: image-320w.png, image-320w.webp

## Example

Given an input image `/assets/images/mikmak/acquisition-rebrand/carousel-research/analytics.png`, the script will:

1. Back up the original:
   - Creates `/assets/images/mikmak/acquisition-rebrand/carousel-research/analytics-original.png`

2. Optimize the source:
   - Optimizes `/assets/images/mikmak/acquisition-rebrand/carousel-research/analytics.png`
   - Creates `/assets/images/mikmak/acquisition-rebrand/carousel-research/analytics.webp`

3. Generate responsive versions:
   ```
   analytics-320w.png   analytics-320w.webp
   analytics-640w.png   analytics-640w.webp
   analytics-960w.png   analytics-960w.webp
   analytics-1200w.png  analytics-1200w.webp
   analytics-1800w.png  analytics-1800w.webp
   ```

All generated images maintain the same relative path structure as the source image.

## Example Output

For an input image `hero.png`, the script generates:
```
hero-original.png    (preserved original)
hero.png            (optimized original)
hero.webp           (WebP version)
hero-320w.png       hero-320w.webp
hero-640w.png       hero-640w.webp
hero-960w.png       hero-960w.webp
hero-1200w.png      hero-1200w.webp
hero-1800w.png      hero-1800w.webp
```

## Skip Logic

The script intelligently skips processing by:
- Checking filenames for existing size suffixes (-320w, -640w, etc.)
- Detecting any existing processed versions in the same directory
- Skipping if original backup exists (-original suffix)
- Avoiding re-processing of WebP conversions

For example, if any of these exist for `image.png`:
```
image-original.png
image-320w.png
image-640w.png
image.webp
```
The script will skip processing that image.

## Error Handling

- Logs skipped files with reason
- Reports processing errors for individual images
- Continues processing other images if one fails
- Maintains original files on error

## Examples

### Skipping Already Processed Images:
```bash
$ npm run process-images
Skipping featured-image.png - processed versions exist
Processing new-image.png
Generated new-image-320w.png
...
```

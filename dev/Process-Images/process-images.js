#!/usr/bin/env node

const sharp = require('sharp');
const fs = require('fs').promises;
const path = require('path');
const yargs = require('yargs');
const { hideBin } = require('yargs/helpers');

const SIZES = [320, 640, 960, 1200, 1800];
const FORMATS = ['webp', 'png'];

// Add folder mapping for organizing different image types
const FOLDER_STRUCTURE = {
    'carousel-research': true,
    'carousel-data-vizualization': true,
    'carousel-accessibility': true,
    'carousel-component-database': true,
    'carousel-3-platforms': true  // Add this line
};

const argv = yargs(hideBin(process.argv))
    .option('dir', {
        alias: 'd',
        type: 'string',
        description: 'Directory to process',
        default: path.join(__dirname, '../../public_html/assets/images')
    })
    .argv;

const INPUT_DIR = argv.dir;

async function generateResponsiveImage(inputPath, width, format) {
    const dir = path.dirname(inputPath);
    const filename = path.basename(inputPath, path.extname(inputPath));
    const outputPath = path.join(dir, `${filename}-${width}w.${format}`);

    try {
        const transform = sharp(inputPath).resize(width);
        
        if (format === 'webp') {
            await transform.webp({ quality: 85 }).toFile(outputPath);
        } else {
            await transform.png({ quality: 85 }).toFile(outputPath);
        }
        
        console.log(`Generated ${outputPath}`);
    } catch (err) {
        console.error(`Error processing ${inputPath} at width ${width}:`, err);
    }
}

async function processOriginalImage(inputPath) {
    const dir = path.dirname(inputPath);
    const filename = path.basename(inputPath, path.extname(inputPath));
    
    try {
        // Create backup of original file with -original suffix
        await fs.copyFile(inputPath, path.join(dir, `${filename}-original.png`));
        
        // Optimize the original file in place
        await sharp(inputPath)
            .png({ quality: 85 })
            .toBuffer()
            .then(async (buffer) => {
                await fs.writeFile(inputPath, buffer);
            });
        
        // Create WebP version
        await sharp(inputPath)
            .webp({ quality: 85 })
            .toFile(path.join(dir, `${filename}.webp`));
            
        console.log(`Preserved original and optimized ${inputPath}`);
    } catch (err) {
        console.error(`Error processing original ${inputPath}:`, err);
    }
}

async function processImage(imagePath) {
    // Process original first
    await processOriginalImage(imagePath);
    
    // Then process responsive sizes
    for (const size of SIZES) {
        for (const format of FORMATS) {
            await generateResponsiveImage(imagePath, size, format);
        }
    }
}

async function isAlreadyProcessed(imagePath) {
    const dir = path.dirname(imagePath);
    const filename = path.basename(imagePath, path.extname(imagePath));
    
    // Define the suffixes we're looking for
    const suffixes = ['-320w', '-640w', '-960w', '-1200w', '-1800w', '-original'];
    
    try {
        const files = await fs.readdir(dir);
        // Check if any file in the directory starts with our filename and contains any of our suffixes
        const hasProcessedVersions = files.some(file => 
            suffixes.some(suffix => file.startsWith(filename) && file.includes(suffix))
        );
        
        if (hasProcessedVersions) {
            console.log(`Skipping ${filename} - processed versions exist`);
            return true;
        }
        return false;
    } catch (err) {
        console.error(`Error checking processed versions for ${imagePath}:`, err);
        return false;
    }
}

async function processDirectory(directory) {
    try {
        const entries = await fs.readdir(directory, { withFileTypes: true });
        
        for (const entry of entries) {
            const fullPath = path.join(directory, entry.name);
            
            if (entry.isDirectory()) {
                const relativePath = path.relative(INPUT_DIR, fullPath);
                if (FOLDER_STRUCTURE[relativePath] || relativePath === '') {
                    await processDirectory(fullPath);
                }
            } else if (entry.isFile() && /\.(png|jpe?g)$/i.test(entry.name)) {
                // Skip if file has dimensions in name or if any processed versions exist
                if (!entry.name.match(/-\d+w\.(png|webp)$/) && !await isAlreadyProcessed(fullPath)) {
                    console.log(`Processing ${fullPath}`);
                    await processImage(fullPath);
                }
            }
        }
    } catch (err) {
        console.error(`Error processing directory ${directory}:`, err);
    }
}

// Start processing
processDirectory(INPUT_DIR)
    .then(() => console.log('Image processing complete'))
    .catch(err => console.error('Error:', err));
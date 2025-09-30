# Visual Polish Scripts

Automation scripts for Familiar app visual polish workflow.

## Available Scripts

### 🔍 screenshot-compare.sh

Compare before/after screenshots with visual diff generation.

```bash
./screenshot-compare.sh before.png after.png sidebar-changes
```

**Output:**

- Pixel-level diff image highlighting changes
- Side-by-side comparison for presentations
- RMSE difference metric for quantitative analysis

### 🎬 create-demo-gif.sh

Convert screen recordings to optimized demo GIFs.

```bash
./create-demo-gif.sh screen-recording.mov animation-demo 15 800
```

**Parameters:**

- `fps` (default: 12) - Frame rate for smoothness vs size balance
- `width` (default: 800) - Pixel width for appropriate detail level

### ♿ accessibility-check.sh

Comprehensive accessibility audit for the running app.

```bash
./accessibility-check.sh http://localhost:8765 ui-audit
```

**Features:**

- Full axe-core accessibility scan
- Color contrast ratio verification for common UI colors
- JSON report generation with detailed findings

## Prerequisites

Ensure the backend is running before accessibility checks:

```bash
cd backend
uv run uvicorn palette_sidecar.api:app --host 127.0.0.1 --port 8765 --reload
```

## Tool Status

### ✅ Working Commands

- `ffmpeg` - Video/audio processing
- `gifsicle` - GIF optimization
- `magick` (ImageMagick) - Image manipulation
- `xcbeautify` - Swift build log formatting
- `svgo` - SVG optimization
- `/Users/alexanderhuth/Library/Python/3.9/bin/shot-scraper` - Screenshot automation

### ⚠️ Tool Notes

- **shot-scraper**: Requires full path until PATH updated in new shell sessions
- **axe-core**: Installed as library, requires custom script integration
- **color-contrast-checker**: Available as node module, needs wrapper script

## Quick Start

1. Make scripts executable (already done):

   ```bash
   chmod +x *.sh
   ```

2. Test core functionality:

   ```bash
   # Create a test screenshot
   /Users/alexanderhuth/Library/Python/3.9/bin/shot-scraper https://example.com -o test.png

   # Optimize an SVG
   svgo input.svg -o output.svg

   # Convert video to GIF (if you have a .mov file)
   ./create-demo-gif.sh your-recording.mov
   ```

## Best Practices

- **Screenshots**: Use consistent viewport sizes for comparisons
- **GIFs**: Keep under 2MB for easy sharing (adjust fps/width as needed)
- **Accessibility**: Run checks after each UI iteration
- **Version Control**: Include visual-diffs/ and demo-gifs/ in .gitignore

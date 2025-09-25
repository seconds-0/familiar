# Visual Polish Tooling Installation & Acquisition Guide

Complete toolkit for the Familiar visual polish sprint, organized by installation status and acquisition method.

## ✅ Successfully Installed Tools

### Command-Line Tools (Homebrew)
- **ffmpeg** - Video/audio processing and transcoding
  - `ffmpeg -i input.mov output.gif` - Convert to GIF for sharing
  - `ffmpeg -i recording.mov -vf "fps=10,scale=640:-1:flags=lanczos" output.gif` - Optimized GIF export

- **gifsicle** - GIF optimization and processing
  - `gifsicle --optimize=3 --colors=128 input.gif > output.gif` - Optimize GIF size
  - `gifsicle --batch --optimize=3 *.gif` - Batch optimize all GIFs

- **imagemagick** - Comprehensive image manipulation
  - `magick compare before.png after.png diff.png` - Generate visual diff
  - `magick montage before.png after.png -geometry 640x480+10+10 comparison.png` - Side-by-side comparison

- **xcbeautify** - Swift build log formatter
  - `xcodebuild | xcbeautify` - Clean build output for polish-related checks

### Node.js Tools (NPM Global)
- **color-contrast-checker** - WCAG compliance verification
  - `color-contrast-checker --foreground="#333" --background="#fff"` - Check contrast ratios

- **axe-core** - Accessibility audit CLI
  - `axe https://localhost:3000` - Run accessibility checks on running app

- **svgo** - SVG optimization
  - `svgo input.svg -o output.svg` - Optimize SVG assets before handoff

### Python Tools
- **shot-scraper** - Automated screenshot capture
  - `shot-scraper http://localhost:3000 -o app-state.png` - Capture app states for regression tracking
  - Note: Installed in `/Users/alexanderhuth/Library/Python/3.9/bin/shot-scraper`

## 🛒 Tools Requiring Manual Acquisition

### Design & Ideation
- **Figma (Web/Desktop)**
  - Free tier available: https://www.figma.com
  - Pro plan: $15/month for advanced features
  - Purpose: Primary canvas for UI tweaks, component overlays, collaborative comments

- **SF Symbols Beta**
  - Free from Apple Developer Program
  - Download: https://developer.apple.com/sf-symbols/
  - Purpose: Access latest glyph library for macOS consistency

- **Apple Design Resources**
  - Free Sketch/Keynote templates
  - Download: https://developer.apple.com/design/resources/
  - Purpose: Native macOS UI kits for consistent mockups

### Capture & Annotation

#### Premium Options ($40-60)
- **CleanShot X** - Professional screenshot tool
  - Purchase: Mac App Store or https://cleanshot.com
  - Features: Pixel rulers, annotations, quick sharing
  - Price: ~$60 one-time

- **xScope** - Live measurement overlay tool
  - Purchase: Mac App Store
  - Features: On-screen rulers, live measurement while app runs
  - Price: ~$50 one-time

- **PixelSnap** - Precision measurement tool
  - Purchase: Mac App Store
  - Features: Pixel-perfect measurements, color picking
  - Price: ~$40 one-time

#### Free Alternatives
- **Shottr** - Free screenshot tool
  - Download: https://shottr.cc
  - Features: Basic annotations, measurements
  - Price: Free with premium features available

### Motion & Interaction Prototyping
- **Principle** - Animation prototyping
  - Purchase: https://principleformac.com
  - Purpose: Storyboard loading, hover, sheet transitions
  - Price: ~$60 one-time

- **Figma Smart Animate** (included in Figma)
  - Built into Figma interface
  - Purpose: Lightweight motion prototypes

- **Keynote** (likely already installed)
  - Part of macOS/iWork suite
  - Purpose: Simple animation prototypes

### Accessibility & Color Tools

#### Desktop Apps
- **contrast.app** - Quick contrast checker
  - Download: https://usecontrast.com
  - Price: Free tier, $9 pro version

- **Stark** (Figma/Sketch plugin)
  - Install via plugin managers
  - Purpose: Design-time accessibility checking

### Typography & Token Management
- **Type Scale** (Web tool)
  - Use online: https://typescale.com
  - Purpose: Generate harmonious typography scales for SwiftUI

- **Style Dictionary**
  - Setup: `npm install -g style-dictionary`
  - Purpose: Manage design tokens that propagate to SwiftUI code

- **Font Book** (Pre-installed on macOS)
  - Purpose: Curate and export preferred font weights/cuts

### Documentation & Collaboration
- **Notion** - Design documentation hub
  - Signup: https://notion.so
  - Purpose: Polish checklist, feedback threads, before/after embeds
  - Price: Free for personal use

- **Loom** - Video walkthroughs
  - Signup: https://loom.com
  - Purpose: Async explanations of proposed changes
  - Price: Free tier available, $12/month for unlimited videos

## 🔧 Project Setup Tasks

### Assets Playground Setup
Create dedicated asset staging area:
```bash
# Navigate to Xcode project
cd apps/mac/FamiliarApp/Sources/FamiliarApp
mkdir -p Resources
# Create playground asset catalog (to be done in Xcode)
# File > New > iOS > Resource > Asset Catalog
# Name: Assets-Playground.xcassets
```

### PATH Configuration
Add Python tools to PATH by adding to `~/.zshrc`:
```bash
echo 'export PATH="$PATH:/Users/alexanderhuth/Library/Python/3.9/bin"' >> ~/.zshrc
source ~/.zshrc
```

## 🧪 Testing Commands

### Verify Installations
```bash
# Core media tools
ffmpeg -version
gifsicle --version
magick -version
xcbeautify --version

# Node.js tools
color-contrast-checker --version
axe --version
svgo --version

# Python tools
shot-scraper --version
```

### Example Workflows

#### Screenshot Regression Testing
```bash
# Capture before state
shot-scraper http://localhost:3000 -o before.png

# Make changes, then capture after state
shot-scraper http://localhost:3000 -o after.png

# Generate visual diff
magick compare before.png after.png diff.png
```

#### GIF Creation for Reviews
```bash
# Record with QuickTime, then convert
ffmpeg -i screen-recording.mov -vf "fps=15,scale=800:-1:flags=lanczos" demo.gif
gifsicle --optimize=3 --colors=128 demo.gif -o demo-optimized.gif
```

#### Accessibility Check
```bash
# Check contrast ratios
color-contrast-checker --foreground="#2D3748" --background="#F7FAFC"

# Full accessibility audit (when app is running)
axe http://localhost:8765
```

## 💡 Usage Insights

`★ Insight ─────────────────────────────────────`
• This toolchain covers the complete visual polish workflow from design through delivery
• Free alternatives exist for most paid tools, allowing gradual toolkit expansion
• Command-line tools enable scriptable visual regression testing and automated optimization
`─────────────────────────────────────────────────`

## 📊 Cost Summary

### Immediate Free Tools: $0
- All CLI tools (ffmpeg, gifsicle, imagemagick, etc.)
- Figma free tier, Shottr, contrast.app free
- Web-based tools (Type Scale, etc.)

### Premium Additions: ~$200-300
- CleanShot X ($60) or PixelSnap ($40)
- xScope ($50)
- Principle ($60)
- Loom Pro ($12/month)
- Notion Pro ($10/month for teams)

### Recommended First Purchases
1. **CleanShot X** ($60) - Biggest productivity boost for screenshots
2. **Loom** ($12/month) - Essential for async design communication
3. **Figma Pro** ($15/month) - When collaboration needs exceed free tier
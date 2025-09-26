# Familiar Visual Polish Toolkit

This note summarizes the key utilities and references available for the polish sprint. For the full acquisition and usage guide, see `docs/visual-polish-tooling-guide.md`. Script details live in `scripts/visual-polish/README.md`.

## Installed CLI Stack
- **Swiftformat** – `swiftformat apps/mac/FamiliarApp` to format SwiftUI changes.
- **Swiftlint** – `swiftlint lint --path apps/mac/FamiliarApp` for lint checks.
- **FFmpeg 8.0** – video/GIF processing; pair with `scripts/visual-polish/create-demo-gif.sh`.
- **Gifsicle 1.96** – optimize GIF outputs after FFmpeg conversions.
- **ImageMagick 7.1.2-3** – run `magick compare` for visual diffs.
- **xcbeautify 2.30.1** – pipe `xcodebuild` output for readable polish-focused builds.
- **SVGO 4.0.0** – clean SVG assets before handoff.
- **shot-scraper 1.8** – automated screenshot capture (current path: `/Users/alexanderhuth/Library/Python/3.9/bin/shot-scraper`).

## Automation Scripts
Located in `scripts/visual-polish/` and already executable:
- `screenshot-compare.sh before.png after.png feature-name`
- `create-demo-gif.sh recording.mov demo-name [fps] [width]`
- `accessibility-check.sh http://localhost:8765 [label]`
These scripts output to `visual-diffs/`, `demo-gifs/`, and `accessibility-reports/` respectively.

## Built-In Utilities
- **QuickTime Player** – record summon → prompt → result walkthroughs.
- **xcrun simctl** – `xcrun simctl io booted recordVideo output.mp4` for simulator captures.
- **Accessibility Inspector** – validate focus order, labels, and contrast.
- **SF Symbols app** – explore glyph options before proposing custom icons.

## Premium & Optional Tools
On hold unless explicitly requested: CleanShot X, Loom, Figma Pro, Principle, xScope/PixelSnap. Free alternates like Shottr, Figma free tier, contrast.app remain available.

## Next Steps
- Extend design token workflow (e.g., Style Dictionary) when palette decisions land.
- Keep the toolkit docs updated as we integrate additional utilities or refine scripts.

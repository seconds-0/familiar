#!/bin/bash
# Create optimized demo GIFs from screen recordings
# Usage: ./create-demo-gif.sh <input.mov> [output_name] [fps] [width]

set -e

if [ $# -lt 1 ]; then
    echo "Usage: $0 <input.mov> [output_name] [fps] [width]"
    echo "Example: $0 screen-recording.mov sidebar-animation 15 800"
    echo ""
    echo "Defaults:"
    echo "  fps: 12"
    echo "  width: 800"
    echo "  output_name: derived from input filename"
    exit 1
fi

INPUT="$1"
OUTPUT_NAME="${2:-$(basename "$INPUT" .mov)}"
FPS="${3:-12}"
WIDTH="${4:-800}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="demo-gifs"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Verify input file exists
if [ ! -f "$INPUT" ]; then
    echo "Error: Input file '$INPUT' not found"
    exit 1
fi

echo "🎬 Creating demo GIF..."
echo "  Input: $INPUT"
echo "  FPS: $FPS"
echo "  Width: ${WIDTH}px"

# Step 1: Convert to GIF with ffmpeg
TEMP_GIF="temp_${TIMESTAMP}.gif"
ffmpeg -i "$INPUT" -vf "fps=$FPS,scale=$WIDTH:-1:flags=lanczos,palettegen=reserve_transparent=0" -y palette.png
ffmpeg -i "$INPUT" -i palette.png -vf "fps=$FPS,scale=$WIDTH:-1:flags=lanczos,paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" -y "$TEMP_GIF"

# Step 2: Optimize with gifsicle
OUTPUT_GIF="$OUTPUT_DIR/${OUTPUT_NAME}_${TIMESTAMP}.gif"
gifsicle --optimize=3 --colors=128 --lossy=80 "$TEMP_GIF" > "$OUTPUT_GIF"

# Cleanup
rm palette.png "$TEMP_GIF"

# Get file size
SIZE=$(ls -lh "$OUTPUT_GIF" | awk '{print $5}')

echo "✅ Demo GIF created:"
echo "  File: $OUTPUT_GIF"
echo "  Size: $SIZE"
echo ""
echo "💡 Sharing tips:"
echo "  - Drag to Slack/Discord for easy sharing"
echo "  - Embed in GitHub issues/PRs"
echo "  - Use for before/after comparisons"
echo ""
echo "🔧 Optimization options:"
echo "  - Reduce fps for smaller size (try 8-10)"
echo "  - Reduce width for mobile-friendly demos"
echo "  - Increase --lossy value (up to 200) for smaller files"
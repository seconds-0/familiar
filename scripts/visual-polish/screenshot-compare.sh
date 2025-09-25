#!/bin/bash
# Visual Polish Screenshot Comparison Tool
# Usage: ./screenshot-compare.sh <before.png> <after.png> [output_name]

set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 <before.png> <after.png> [output_name]"
    echo "Example: $0 before.png after.png sidebar-changes"
    exit 1
fi

BEFORE="$1"
AFTER="$2"
OUTPUT_NAME="${3:-comparison}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="visual-diffs"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Verify input files exist
if [ ! -f "$BEFORE" ]; then
    echo "Error: Before image '$BEFORE' not found"
    exit 1
fi

if [ ! -f "$AFTER" ]; then
    echo "Error: After image '$AFTER' not found"
    exit 1
fi

echo "🔍 Comparing images..."
echo "  Before: $BEFORE"
echo "  After:  $AFTER"

# Generate diff image
DIFF_FILE="$OUTPUT_DIR/${OUTPUT_NAME}_diff_${TIMESTAMP}.png"
magick compare "$BEFORE" "$AFTER" "$DIFF_FILE"

# Create side-by-side comparison
COMPOSITE_FILE="$OUTPUT_DIR/${OUTPUT_NAME}_composite_${TIMESTAMP}.png"
magick montage "$BEFORE" "$AFTER" -geometry +10+10 -title "Before vs After" "$COMPOSITE_FILE"

# Generate metrics
METRIC=$(magick compare -metric RMSE "$BEFORE" "$AFTER" null: 2>&1 | head -n1)

echo "✅ Comparison complete:"
echo "  Diff image: $DIFF_FILE"
echo "  Side-by-side: $COMPOSITE_FILE"
echo "  Difference metric: $METRIC"
echo ""
echo "💡 Next steps:"
echo "  - Review diff image for pixel-level changes"
echo "  - Use composite for presentation/documentation"
echo "  - Lower RMSE values indicate smaller visual differences"
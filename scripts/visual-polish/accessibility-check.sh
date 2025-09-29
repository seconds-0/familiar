#!/bin/bash
# Comprehensive accessibility checking for Familiar app
# Usage: ./accessibility-check.sh [app_url] [report_name]

set -e

APP_URL="${1:-http://localhost:8765}"
REPORT_NAME="${2:-accessibility-audit}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="accessibility-reports"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "♿ Running accessibility audit..."
echo "  Target: $APP_URL"
echo "  Report: ${REPORT_NAME}_${TIMESTAMP}"

# Check if app is running
echo "🔍 Checking if app is accessible..."
if ! curl -s --connect-timeout 5 "$APP_URL" > /dev/null; then
    echo "⚠️  App not reachable at $APP_URL"
    echo "   Make sure the Familiar backend is running:"
    echo "   cd backend && uv run uvicorn palette_sidecar.api:app --host 127.0.0.1 --port 8765 --reload"
    exit 1
fi

# Run axe-core audit
REPORT_FILE="$OUTPUT_DIR/${REPORT_NAME}_${TIMESTAMP}.json"
echo "🧪 Running axe-core audit..."
axe "$APP_URL" --save "$REPORT_FILE" --reporter json || true

# Color contrast spot checks (common Familiar app colors)
echo ""
echo "🎨 Checking color contrast ratios..."

# Define color pairs to check (background/foreground)
declare -a color_checks=(
    "#FFFFFF,#333333,Main text on white"
    "#F7FAFC,#2D3748,Secondary text on light gray"
    "#4A5568,#FFFFFF,White text on medium gray"
    "#2B6CB0,#FFFFFF,White text on blue (primary buttons)"
    "#E53E3E,#FFFFFF,White text on red (error states)"
    "#38A169,#FFFFFF,White text on green (success states)"
)

for check in "${color_checks[@]}"; do
    IFS=',' read -r bg fg label <<< "$check"
    echo "  Testing: $label"
    color-contrast-checker --background="$bg" --foreground="$fg" --verbose || echo "    ❌ Failed WCAG standards"
done

# Generate summary
if [ -f "$REPORT_FILE" ]; then
    VIOLATIONS=$(jq '.violations | length' "$REPORT_FILE" 2>/dev/null || echo "unknown")
    echo ""
    echo "📊 Audit Summary:"
    echo "  Full report: $REPORT_FILE"
    echo "  Violations found: $VIOLATIONS"
    echo ""

    if [ "$VIOLATIONS" != "0" ] && [ "$VIOLATIONS" != "unknown" ]; then
        echo "🔧 Common fixes:"
        echo "  - Increase color contrast ratios"
        echo "  - Add proper ARIA labels and roles"
        echo "  - Ensure keyboard navigation works"
        echo "  - Provide alternative text for images"
    else
        echo "✅ No accessibility violations detected!"
    fi
else
    echo "⚠️  Could not generate detailed report"
fi

echo ""
echo "💡 Next steps:"
echo "  - Review JSON report for detailed violations"
echo "  - Test with actual screen readers (VoiceOver on macOS)"
echo "  - Verify keyboard-only navigation works"
echo "  - Consider automated testing in CI/CD pipeline"
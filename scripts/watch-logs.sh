#!/usr/bin/env bash
# Watch logs from Familiar app in real-time

echo "📋 Streaming logs from FamiliarApp..."
echo "   Press Ctrl+C to stop"
echo ""

# Stream system logs for FamiliarApp with our subsystem
log stream --predicate 'subsystem == "com.familiar.app"' --level info --style compact --color always

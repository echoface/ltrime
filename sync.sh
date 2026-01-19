#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CUSTOMS_DIR="$SCRIPT_DIR/customs"

for dir in rime-ice rime-frost; do
    if [ -d "$dir" ]; then
        echo "Syncing $dir..."
        (cd "$dir" && git pull)
        
        if [ -d "$CUSTOMS_DIR" ]; then
            echo "Deploying custom configurations to $dir..."
            cp -v "$CUSTOMS_DIR"/*.yaml "$SCRIPT_DIR/$dir/" 2>/dev/null || true
        fi
    fi
done

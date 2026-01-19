#!/bin/bash
for dir in rime-ice rime-frost; do
    if [ -d "$dir" ]; then
        echo "Syncing $dir..."
        (cd "$dir" && git pull)
    fi
done

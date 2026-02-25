#!/bin/bash
# Install Conductor for multiple AI shells
# Usage: ./install.sh

set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"

if [ -x "$ROOT/skill/scripts/install.sh" ]; then
    exec "$ROOT/skill/scripts/install.sh" "$@"
else
    echo "Error: Could not find skill/scripts/install.sh"
    exit 1
fi

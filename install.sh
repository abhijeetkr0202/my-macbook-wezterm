#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting dotfiles installation..."
echo

bash "$SCRIPT_DIR/scripts/brew.sh"

echo

bash "$SCRIPT_DIR/scripts/wezterm.sh"

echo
echo "🎉 Installation complete!"
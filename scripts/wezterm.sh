#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/utils.sh"

info "Configuring WezTerm..."

create_symlink \
    "$REPO_ROOT/configs/wezterm/wezterm.lua" \
    "$HOME/.config/wezterm/wezterm.lua"

success "WezTerm configured."
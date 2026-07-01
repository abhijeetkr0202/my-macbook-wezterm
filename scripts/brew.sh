#!/bin/bash

set -e

source "$(dirname "$0")/utils.sh"

info "Checking Homebrew..."

if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew..."

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    success "Homebrew already installed."
fi

info "Installing packages..."

brew bundle --file=Brewfile

success "Packages installed."
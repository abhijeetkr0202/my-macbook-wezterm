#!/bin/bash

set -e

info() {
    echo "ℹ️  $1"
}

success() {
    echo "✅ $1"
}

warning() {
    echo "⚠️  $1"
}

error() {
    echo "❌ $1"
}

create_symlink() {
    local source="$1"
    local destination="$2"

    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$destination")"

    # If the destination is already the correct symlink, do nothing
    if [ -L "$destination" ]; then
        if [ "$(readlink "$destination")" = "$source" ]; then
            success "$destination already linked."
            return
        fi
    fi

    # Backup existing file or directory
    if [ -e "$destination" ] || [ -L "$destination" ]; then
        warning "Backing up $destination"
        mv "$destination" "$destination.backup"
    fi

    ln -s "$source" "$destination"

    success "Linked $destination"
}
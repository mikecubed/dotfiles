#!/usr/bin/env bash
# scripts/install-neovim.sh — Install or update Neovim to the latest stable version
set -euo pipefail

INSTALL_DIR="/usr/local/bin"

get_latest_version() {
    curl -sL "https://api.github.com/repos/neovim/neovim/releases/latest" \
        | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/'
}

install_neovim_appimage() {
    local version="$1"
    local tmpdir
    tmpdir="$(mktemp -d)"

    echo "Downloading Neovim ${version} AppImage..."
    curl -sL "https://github.com/neovim/neovim/releases/download/${version}/nvim-linux-x86_64.appimage" \
        -o "${tmpdir}/nvim"
    chmod +x "${tmpdir}/nvim"

    echo "Installing to ${INSTALL_DIR}/nvim..."
    sudo mv "${tmpdir}/nvim" "${INSTALL_DIR}/nvim"
    rm -rf "$tmpdir"
    hash -r
}

echo "Checking Neovim installation..."

LATEST="$(get_latest_version)"
if [[ -z "$LATEST" ]]; then
    echo "Warning: could not fetch latest Neovim version from GitHub."
    echo "Falling back to package manager install."
    if [[ "$(uname)" == "Darwin" ]]; then
        brew install neovim
    else
        sudo apt-get update -qq && sudo apt-get install -y neovim
    fi
    echo "Neovim installed: $(nvim --version | head -1)"
    exit 0
fi

echo "Latest Neovim release: ${LATEST}"

if command -v nvim &>/dev/null; then
    CURRENT="v$(nvim --version | head -1 | grep -oP '\d+\.\d+\.\d+')"
    echo "Current Neovim version: ${CURRENT}"
    if [[ "$CURRENT" == "$LATEST" ]]; then
        echo "Neovim is already up to date."
        exit 0
    fi
    echo "Updating Neovim ${CURRENT} -> ${LATEST}..."
else
    echo "Neovim is not installed. Installing ${LATEST}..."
fi

if [[ "$(uname)" == "Darwin" ]]; then
    brew install neovim || brew upgrade neovim
else
    install_neovim_appimage "$LATEST"
fi

echo "Done. Neovim installed: $(nvim --version | head -1)"

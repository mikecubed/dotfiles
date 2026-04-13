#!/usr/bin/env bash
# scripts/install-tmux.sh — Install or update tmux to the latest version
set -euo pipefail

get_latest_version() {
    curl -sL "https://api.github.com/repos/tmux/tmux/releases/latest" \
        | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/'
}

install_tmux_from_source() {
    local version="$1"
    local build_dir
    build_dir="$(mktemp -d)"

    echo "Installing build dependencies..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq libevent-dev ncurses-dev build-essential bison pkg-config

    echo "Downloading tmux ${version}..."
    curl -sL "https://github.com/tmux/tmux/releases/download/${version}/tmux-${version}.tar.gz" \
        | tar -xz -C "$build_dir"

    echo "Building tmux ${version}..."
    cd "${build_dir}/tmux-${version}"
    ./configure --prefix=/usr/local
    make -j"$(nproc)"
    sudo make install

    rm -rf "$build_dir"
    hash -r
}

echo "Checking tmux installation..."

LATEST="$(get_latest_version)"
if [[ -z "$LATEST" ]]; then
    echo "Warning: could not fetch latest tmux version from GitHub."
    echo "Falling back to package manager install."
    if [[ "$(uname)" == "Darwin" ]]; then
        brew install tmux
    else
        sudo apt-get update -qq && sudo apt-get install -y tmux
    fi
    echo "tmux installed: $(tmux -V)"
    exit 0
fi

echo "Latest tmux release: ${LATEST}"

if command -v tmux &>/dev/null; then
    CURRENT="$(tmux -V | awk '{print $2}')"
    echo "Current tmux version: ${CURRENT}"
    if [[ "$CURRENT" == "$LATEST" ]]; then
        echo "tmux is already up to date."
        exit 0
    fi
    echo "Updating tmux ${CURRENT} -> ${LATEST}..."
else
    echo "tmux is not installed. Installing ${LATEST}..."
fi

if [[ "$(uname)" == "Darwin" ]]; then
    brew install tmux || brew upgrade tmux
else
    install_tmux_from_source "$LATEST"
fi

echo "Done. tmux installed: $(tmux -V)"

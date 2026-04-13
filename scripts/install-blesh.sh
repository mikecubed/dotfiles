#!/usr/bin/env bash
# scripts/install-blesh.sh — Install ble.sh (Bash Line Editor)
set -euo pipefail

BLESH_DIR="${HOME}/.local/share/blesh"

echo "Checking ble.sh installation..."

if [[ -f "${BLESH_DIR}/ble.sh" ]]; then
    echo "ble.sh is already installed at ${BLESH_DIR}"
    read -rp "Reinstall / update ble.sh? [y/N] " answer
    if [[ "${answer,,}" != "y" ]]; then
        echo "Skipping."
        exit 0
    fi
fi

echo "Installing build dependencies..."
if command -v apt-get &>/dev/null; then
    sudo apt-get update -qq
    sudo apt-get install -y -qq gawk make
elif command -v brew &>/dev/null; then
    brew install gawk make
fi

BUILD_DIR="$(mktemp -d)"
echo "Cloning ble.sh..."
git clone --recursive --depth 1 --shallow-submodules \
    https://github.com/akinomyoga/ble.sh.git "$BUILD_DIR/ble.sh"

echo "Building ble.sh..."
cd "$BUILD_DIR/ble.sh"
make -j"$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 1)"
make install PREFIX="$HOME/.local"

rm -rf "$BUILD_DIR"

# Ensure .bashrc has ble.sh init
BASHRC="$HOME/.bashrc"
INIT_LINE='[[ $- == *i* ]] && source ~/.local/share/blesh/ble.sh --noattach'
ATTACH_LINE='[[ ${BLE_VERSION-} ]] && ble-attach'

if [[ -f "$BASHRC" ]] && grep -qF 'blesh/ble.sh' "$BASHRC"; then
    echo "ble.sh init already in ${BASHRC}"
else
    # ble.sh needs to be sourced near the top and attached at the bottom
    {
        echo ""
        echo "# ble.sh - Bash Line Editor"
        echo "$INIT_LINE"
    } >> "$BASHRC"

    # Append attach line at the very end
    {
        echo ""
        echo "# ble.sh attach (must be last)"
        echo "$ATTACH_LINE"
    } >> "$BASHRC"

    echo "Added ble.sh init to ${BASHRC}"
fi

echo "Done. Restart your shell or run: source ~/.bashrc"

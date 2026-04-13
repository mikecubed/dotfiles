#!/usr/bin/env bash
# install.sh — Deploy dotfiles on Linux/macOS
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Helper ---
link_config() {
    local src="$1"
    local dest="$2"

    if [[ -L "$dest" ]]; then
        local current
        current="$(readlink "$dest")"
        if [[ "$current" == "$src" ]]; then
            echo "  ok  $dest -> $src"
            return
        fi
        echo "  update  $dest -> $src (was $current)"
        rm "$dest"
    elif [[ -e "$dest" ]]; then
        echo "  backup  $dest -> ${dest}.bak"
        mv "$dest" "${dest}.bak"
    else
        echo "  link  $dest -> $src"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
}

echo "Deploying dotfiles from $DOTFILES_DIR"
echo ""

# --- Neovim (LazyVim) ---
echo "[nvim]"
link_config "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# --- tmux ---
echo "[tmux]"
link_config "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

echo ""
echo "Symlinks created."
echo ""

# --- Optional: install/update tmux ---
if ! command -v tmux &>/dev/null; then
    read -rp "tmux is not installed. Install latest version? [y/N] " answer
    if [[ "${answer,,}" == "y" ]]; then
        bash "$DOTFILES_DIR/scripts/install-tmux.sh"
    fi
else
    echo "tmux is installed: $(tmux -V)"
    read -rp "Check for tmux updates? [y/N] " answer
    if [[ "${answer,,}" == "y" ]]; then
        bash "$DOTFILES_DIR/scripts/install-tmux.sh"
    fi
fi

# --- Optional: install/update neovim ---
if ! command -v nvim &>/dev/null; then
    read -rp "Neovim is not installed. Install latest version? [y/N] " answer
    if [[ "${answer,,}" == "y" ]]; then
        bash "$DOTFILES_DIR/scripts/install-neovim.sh"
    fi
else
    echo "Neovim is installed: $(nvim --version | head -1)"
    read -rp "Check for Neovim updates? [y/N] " answer
    if [[ "${answer,,}" == "y" ]]; then
        bash "$DOTFILES_DIR/scripts/install-neovim.sh"
    fi
fi

# --- Optional: install starship if not present ---
if ! command -v starship &>/dev/null; then
    read -rp "starship is not installed. Install it now? [y/N] " answer
    if [[ "${answer,,}" == "y" ]]; then
        bash "$DOTFILES_DIR/scripts/install-starship.sh"
    fi
else
    echo "starship is already installed."
fi

# --- Starship preset selection ---
if command -v starship &>/dev/null; then
    echo ""
    read -rp "Configure starship preset? [y/N] " answer
    if [[ "${answer,,}" == "y" ]]; then
        bash "$DOTFILES_DIR/scripts/setup-starship.sh"
    fi
fi

# --- Optional: install ble.sh (Bash Line Editor) ---
if [[ -f "${HOME}/.local/share/blesh/ble.sh" ]]; then
    echo "ble.sh is already installed."
else
    read -rp "ble.sh (Bash Line Editor) is not installed. Install it? [y/N] " answer
    if [[ "${answer,,}" == "y" ]]; then
        bash "$DOTFILES_DIR/scripts/install-blesh.sh"
    fi
fi

echo ""
echo "Done. You may need to:"
echo "  - Restart tmux:    tmux source-file ~/.tmux.conf"
echo "  - Restart shell:   exec bash"
echo "  - Sync nvim plugins: nvim (lazy.nvim will auto-sync on first launch)"

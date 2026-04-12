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

# --- Starship ---
echo "[starship]"
link_config "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

echo ""
echo "Symlinks created."
echo ""

# --- Optional: install starship if not present ---
if ! command -v starship &>/dev/null; then
    read -rp "starship is not installed. Install it now? [y/N] " answer
    if [[ "${answer,,}" == "y" ]]; then
        bash "$DOTFILES_DIR/scripts/install-starship.sh"
    fi
else
    echo "starship is already installed."
fi

echo ""
echo "Done. You may need to:"
echo "  - Restart tmux:    tmux source-file ~/.tmux.conf"
echo "  - Restart shell:   exec bash"
echo "  - Sync nvim plugins: nvim (lazy.nvim will auto-sync on first launch)"

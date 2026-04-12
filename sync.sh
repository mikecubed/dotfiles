#!/usr/bin/env bash
# sync.sh — Pull latest dotfiles from GitHub and re-run install
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR"

echo "Pulling latest dotfiles..."
git pull --ff-only

echo ""
exec "$DOTFILES_DIR/install.sh"

#!/usr/bin/env bash
# scripts/install-starship.sh — Install starship prompt and enable it in .bashrc
set -euo pipefail

echo "Installing starship prompt..."

if command -v starship &>/dev/null; then
    echo "starship is already installed: $(starship --version | head -1)"
else
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

# Ensure starship init is in .bashrc
BASHRC="$HOME/.bashrc"
if [[ -f "$BASHRC" ]] && grep -q 'eval "$(starship init bash)"' "$BASHRC"; then
    echo "starship init already in $BASHRC"
else
    echo "" >> "$BASHRC"
    echo "# starship prompt" >> "$BASHRC"
    echo 'eval "$(starship init bash)"' >> "$BASHRC"
    echo "Added starship init to $BASHRC"
fi

echo "Done. Restart your shell or run: eval \"\$(starship init bash)\""

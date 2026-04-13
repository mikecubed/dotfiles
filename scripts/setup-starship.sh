#!/usr/bin/env bash
# scripts/setup-starship.sh — Interactive starship preset selector
set -euo pipefail

STARSHIP_CONFIG="${HOME}/.config/starship.toml"

# --- Extract os.symbols from catppuccin-powerline (the source of truth) ---
get_os_symbols() {
    starship preset catppuccin-powerline | sed -n '/^\[os.symbols\]/,/^$/p'
}

# --- Preset list ---
PRESETS=(
    "bracketed-segments"
    "catppuccin-powerline"
    "gruvbox-rainbow"
    "jetpack"
    "nerd-font-symbols"
    "no-empty-icons"
    "no-nerd-font"
    "no-runtime-versions"
    "pastel-powerline"
    "plain-text-symbols"
    "pure-preset"
    "tokyo-night"
)

echo "Available starship presets:"
echo ""
for i in "${!PRESETS[@]}"; do
    printf "  %2d) %s\n" "$((i + 1))" "${PRESETS[$i]}"
done
echo ""
echo "  $(( ${#PRESETS[@]} + 1 ))) Keep current config / skip"
echo ""

while true; do
    read -rp "Select a preset [1-$(( ${#PRESETS[@]} + 1 ))]: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#PRESETS[@]} + 1 )); then
        break
    fi
    echo "Invalid selection. Try again."
done

if (( choice == ${#PRESETS[@]} + 1 )); then
    echo "Keeping current starship config."
    exit 0
fi

PRESET="${PRESETS[$((choice - 1))]}"
echo ""
echo "Applying preset: ${PRESET}"

mkdir -p "$(dirname "$STARSHIP_CONFIG")"
starship preset "$PRESET" -o "$STARSHIP_CONFIG"

# --- Post-processing ---

case "$PRESET" in
    catppuccin-powerline)
        echo ""
        echo "Catppuccin palette options:"
        echo "  1) mocha  (dark, warm)"
        echo "  2) frappe  (medium dark)"
        echo "  3) macchiato (medium)"
        echo "  4) latte  (light)"
        echo ""
        while true; do
            read -rp "Select palette [1-4]: " pchoice
            if [[ "$pchoice" =~ ^[1-4]$ ]]; then break; fi
            echo "Invalid selection. Try again."
        done
        case "$pchoice" in
            1) palette="catppuccin_mocha" ;;
            2) palette="catppuccin_frappe" ;;
            3) palette="catppuccin_macchiato" ;;
            4) palette="catppuccin_latte" ;;
        esac
        sed -i "s/palette = 'catppuccin_mocha'/palette = '${palette}'/" "$STARSHIP_CONFIG"
        echo "Set palette to ${palette}."
        ;;

    tokyo-night)
        # Replace hardcoded Apple icon segment with $os module reference
        perl -pi -e 's/\[.+?\]\(bg:#a3aed2 fg:#090c0c\)/\$os/' "$STARSHIP_CONFIG"

        # Append [os] with the original styling, and [os.symbols] from catppuccin
        {
            echo ""
            echo "[os]"
            echo "disabled = false"
            echo "format = '[ \$symbol ](bg:#a3aed2 fg:#090c0c)'"
            echo ""
            get_os_symbols
        } >> "$STARSHIP_CONFIG"
        echo "Replaced hardcoded icon with \$os module and platform icons."
        ;;

    pastel-powerline)
        # Enable the [os] module (disabled by default in this preset)
        sed -i '/^\[os\]$/,/^disabled/ s/disabled = true/disabled = false/' "$STARSHIP_CONFIG"

        # Append os.symbols from catppuccin preset
        {
            echo ""
            get_os_symbols
        } >> "$STARSHIP_CONFIG"
        echo "Enabled OS detection with platform icons."
        ;;
esac

echo ""
echo "Starship config written to ${STARSHIP_CONFIG}"
echo "Restart your shell to see the new prompt."

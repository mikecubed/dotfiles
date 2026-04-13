# dotfiles

Personal development environment configs. One repo, deployable to Linux/macOS (bash + tmux) and Windows (pwsh + psmux).

## What's included

| Config | Description | Platforms |
|--------|-------------|-----------|
| `nvim/` | Neovim with LazyVim | Linux, macOS, Windows |
| `tmux/` | tmux with Catppuccin Mocha theme | Linux, macOS |
| `starship/` | Starship prompt with Catppuccin Mocha palette | All |
| `psmux/` | psmux (PowerShell multiplexer) | Windows |

## Quick start

### Linux / macOS

```bash
git clone git@github.com:mikecubed/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
./install.sh
```

### Windows (pwsh)

```powershell
git clone git@github.com:mikecubed/dotfiles.git ~\projects\dotfiles
cd ~\projects\dotfiles
.\install.ps1
```

## Syncing on another machine

Already installed? Pull the latest and re-link in one step:

```bash
# Linux/macOS
./sync.sh

# Windows (pwsh)
.\sync.ps1
```

## What the install scripts do

1. Create symlinks from your config locations to this repo:
   - `~/.config/nvim` -> `dotfiles/nvim/`
   - `~/.tmux.conf` -> `dotfiles/tmux/tmux.conf` (Linux/macOS)
   - `~/.config/starship.toml` -> `dotfiles/starship/starship.toml`
   - `~/.config/psmux/psmux.conf` -> `dotfiles/psmux/psmux.conf` (Windows)
2. Offer to install or update tmux and Neovim to the latest GitHub release (Linux/macOS)
3. Offer to install or update psmux and Neovim via winget (Windows)
4. Offer to install starship if it's not found
5. Existing configs are backed up to `*.bak` before overwriting

## Installing tools separately

```bash
# tmux (builds from source on Linux, brew on macOS)
bash scripts/install-tmux.sh

# Neovim (AppImage on Linux, brew on macOS)
bash scripts/install-neovim.sh

# Starship
bash scripts/install-starship.sh

# Windows (pwsh)
.\scripts\install-psmux.ps1
.\scripts\install-neovim.ps1
.\scripts\install-starship.ps1
```

Each script checks the latest GitHub release and skips if already up to date. The starship scripts also add the init line to your shell profile (`.bashrc` or pwsh `$PROFILE`).

## Theme

Everything uses **Catppuccin Mocha**: tmux status bar, starship prompt, and Neovim (via LazyVim's default tokyonight, or switch to catppuccin in your nvim config).

## See also

- [lazynvim-learn](https://github.com/mikecubed/lazynvim-learn) -- Interactive terminal tutorial for learning Neovim and LazyVim
- [tmux-learn](https://github.com/mikecubed/tmux-learn) -- Interactive terminal tutorial for learning tmux

## License

[MIT](LICENSE)

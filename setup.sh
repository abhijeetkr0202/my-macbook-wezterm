#!/usr/bin/env bash
# =============================================================================
# Terminal Environment Setup
# Sets up WezTerm, Neovim, Powerlevel10k, eza, zoxide, and shell plugins
# =============================================================================

set -e

BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
RESET="\033[0m"

step()  { echo -e "\n${BOLD}${CYAN}▶ $1${RESET}"; }
ok()    { echo -e "${GREEN}✔ $1${RESET}"; }
warn()  { echo -e "${YELLOW}⚠ $1${RESET}"; }

# =============================================================================
# 1. Homebrew
# =============================================================================
step "Checking Homebrew"
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for Apple Silicon (the script may not have done it yet)
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  ok "Homebrew already installed"
fi

# =============================================================================
# 2. WezTerm
# =============================================================================
step "Installing WezTerm"
if ! brew list --cask wezterm &>/dev/null; then
  brew install --cask wezterm
  ok "WezTerm installed"
else
  ok "WezTerm already installed"
fi

# WezTerm config
WEZTERM_CONFIG_DIR="$HOME/.config/wezterm"
WEZTERM_CONFIG_FILE="$WEZTERM_CONFIG_DIR/wezterm.lua"
mkdir -p "$WEZTERM_CONFIG_DIR"

if [[ -f "$WEZTERM_CONFIG_FILE" ]]; then
  warn "wezterm.lua already exists — skipping (backup at wezterm.lua.bak)"
  cp "$WEZTERM_CONFIG_FILE" "$WEZTERM_CONFIG_FILE.bak"
else
  cat > "$WEZTERM_CONFIG_FILE" << 'WEZTERM_EOF'
local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "rose-pine-moon"
config.max_fps = 120

config.font = wezterm.font("MesloLGS Nerd Font Mono")

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

config.inactive_pane_hsb = {
  saturation = 0.0,
  brightness = 0.5,
}

config.window_background_opacity = 0.8
config.macos_window_background_blur = 10
config.font_size = 15.0
config.window_frame = {
  font_size = 13.0,
}

local maximize_window = wezterm.action_callback(function(window, pane)
  window:maximize()
end)

config.keys = {
  {
    key = "Enter",
    mods = "CMD",
    action = maximize_window,
  },
  {
    key = "d",
    mods = "CMD",
    action = wezterm.action.SplitHorizontal,
  },
  {
    key = "D",
    mods = "CMD|SHIFT",
    action = wezterm.action.SplitVertical,
  },
}

return config
WEZTERM_EOF
  ok "wezterm.lua written to $WEZTERM_CONFIG_FILE"
fi

# =============================================================================
# 3. MesloLGS Nerd Font Mono
# =============================================================================
step "Installing MesloLGS Nerd Font Mono"
if ! brew list --cask font-meslo-lg-nerd-font &>/dev/null; then
  brew tap homebrew/cask-fonts 2>/dev/null || true
  brew install --cask font-meslo-lg-nerd-font
  ok "Font installed"
else
  ok "Font already installed"
fi

# =============================================================================
# 4. Neovim
# =============================================================================
step "Installing Neovim"
if ! command -v nvim &>/dev/null; then
  brew install neovim
  ok "Neovim installed"
else
  ok "Neovim already installed ($(nvim --version | head -1))"
fi

# =============================================================================
# 5. Shell tools — eza, zoxide
# =============================================================================
step "Installing eza and zoxide"
for pkg in eza zoxide; do
  if ! brew list "$pkg" &>/dev/null; then
    brew install "$pkg"
    ok "$pkg installed"
  else
    ok "$pkg already installed"
  fi
done

# =============================================================================
# 6. Zsh plugins — autosuggestions, syntax-highlighting
# =============================================================================
step "Installing zsh-autosuggestions and zsh-syntax-highlighting"
for pkg in zsh-autosuggestions zsh-syntax-highlighting; do
  if ! brew list "$pkg" &>/dev/null; then
    brew install "$pkg"
    ok "$pkg installed"
  else
    ok "$pkg already installed"
  fi
done

# =============================================================================
# 7. Powerlevel10k
# =============================================================================
step "Installing Powerlevel10k"
if ! brew list powerlevel10k &>/dev/null; then
  brew install powerlevel10k
  ok "Powerlevel10k installed"
else
  ok "Powerlevel10k already installed"
fi

# =============================================================================
# 8. Append to ~/.zshrc (idempotent — only adds lines that aren't there yet)
# =============================================================================
step "Updating ~/.zshrc"

ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"

append_if_missing() {
  local line="$1"
  # grep -qF for literal string match
  if ! grep -qF "$line" "$ZSHRC"; then
    echo "$line" >> "$ZSHRC"
    ok "Added: $line"
  else
    warn "Already present, skipped: $line"
  fi
}

# p10k instant prompt — must be near the very top of .zshrc
P10K_INSTANT_PROMPT='if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi'

if ! grep -qF "p10k-instant-prompt" "$ZSHRC"; then
  # Prepend to the top of .zshrc
  TMP_FILE=$(mktemp)
  echo "$P10K_INSTANT_PROMPT" > "$TMP_FILE"
  echo "" >> "$TMP_FILE"
  cat "$ZSHRC" >> "$TMP_FILE"
  mv "$TMP_FILE" "$ZSHRC"
  ok "Added p10k instant-prompt block at top of .zshrc"
else
  warn "p10k instant-prompt already present, skipped"
fi

# Lines to append at the bottom
append_if_missing 'source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme'
append_if_missing 'alias ls="eza --icons=always"'
append_if_missing 'eval "$(zoxide init zsh)"'
append_if_missing 'alias cd="z"'
append_if_missing '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh'
append_if_missing 'source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh'
append_if_missing 'source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'

# =============================================================================
# Done
# =============================================================================
echo ""
echo -e "${BOLD}${GREEN}============================================${RESET}"
echo -e "${BOLD}${GREEN} Setup complete!${RESET}"
echo -e "${BOLD}${GREEN}============================================${RESET}"
echo ""
echo -e "Next steps:"
echo -e "  1. ${BOLD}Open WezTerm${RESET} (from Applications or Spotlight)"
echo -e "  2. The ${BOLD}Powerlevel10k wizard${RESET} will launch automatically"
echo -e "     and walk you through prompt configuration."
echo -e "  3. If it doesn't start on its own, run: ${BOLD}p10k configure${RESET}"
echo ""
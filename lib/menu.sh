#!/usr/bin/env bash
#
# lib/menu.sh - fzf menu integration for nunchux
#

# Guard against double-sourcing
[[ -n "${NUNCHUX_LIB_MENU_LOADED:-}" ]] && return
NUNCHUX_LIB_MENU_LOADED=1

# Show shortcuts column (toggled with ctrl-/)
SHOW_SHORTCUTS="${SHOW_SHORTCUTS:-}"

# FZF styling defaults (can be overridden in config)
FZF_PROMPT="${FZF_PROMPT:- }"
FZF_POINTER="${FZF_POINTER:-▶}"
FZF_BORDER="${FZF_BORDER:-none}"
FZF_COLORS="${FZF_COLORS:-fg+:white:bold,bg+:-1,hl:cyan,hl+:cyan:bold,pointer:cyan,marker:green,header:gray,border:gray}"

# Label used in borders and popup titles (can be overridden in config)
NUNCHUX_LABEL="${NUNCHUX_LABEL:-nunchux}"
FZF_BORDER_LABEL=" $NUNCHUX_LABEL "

# Build common fzf options array
# Usage: build_fzf_opts opts_array "header text"
build_fzf_opts() {
  local -n opts=$1
  local header="$2"
  opts=(
    --ansi
    --delimiter='\t'
    --with-nth=1
    --tiebreak=begin
    --header="$header"
    --header-first
    --prompt="$FZF_PROMPT"
    --pointer="$FZF_POINTER"
    --layout=reverse
    --height=100%
    --border="$FZF_BORDER"
    --border-label="$FZF_BORDER_LABEL"
    --border-label-pos=3
    --no-preview
    --expect="$SECONDARY_KEY"
    --color="$FZF_COLORS"
  )
}

# Parse fzf selection output (handles --expect keys)
# Returns: key on first line, selection on second
# Usage: parse_fzf_selection "$selection"
parse_fzf_selection() {
  local selection="$1"
  local key selected_line
  key=$(echo "$selection" | head -1)
  selected_line=$(echo "$selection" | tail -1)
  printf '%s\n%s\n' "$key" "$selected_line"
}

# Build fzf --bind options for all registered shortcuts
# Usage: build_shortcut_binds binds_array script_path
build_shortcut_binds() {
  local -n binds=$1
  local script_path="$2"

  for key in "${!SHORTCUT_REGISTRY[@]}"; do
    local item="${SHORTCUT_REGISTRY[$key]}"
    binds+=("--bind=$key:become($script_path --launch-shortcut '$item')")
  done
}

# Build shortcut prefix for menu display
# Usage: prefix=$(build_shortcut_prefix "$shortcut")
build_shortcut_prefix() {
  local shortcut="$1"

  [[ -z "$SHOW_SHORTCUTS" ]] && return

  if [[ -n "$shortcut" ]]; then
    printf '\033[38;5;244m%-9s\033[0m│ ' "[$shortcut]"
  else
    printf '%9s│ ' ""
  fi
}

# vim: ft=bash ts=2 sw=2 et

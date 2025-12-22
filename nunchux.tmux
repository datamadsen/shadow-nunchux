#!/usr/bin/env bash
#
# nunchux.tmux - TPM plugin for nunchux launcher
#
# Add to ~/.tmux.conf:
#   set -g @plugin 'path/to/nunchux'
#
# Options:
#   set -g @nunchux-key "g"              # Keybinding (default: g)
#   set -g @nunchux-popup-width "60%"    # Menu popup width
#   set -g @nunchux-popup-height "50%"   # Menu popup height
#   set -g @nunchux-app-width "90%"      # App popup width
#   set -g @nunchux-app-height "90%"     # App popup height
#

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NUNCHUCKS_CMD="$CURRENT_DIR/bin/nunchux"

get_tmux_option() {
    local option="$1"
    local default_value="$2"
    local value
    value=$(tmux show-option -gqv "$option")
    echo "${value:-$default_value}"
}

main() {
    local key width height
    key=$(get_tmux_option "@nunchux-key" "g")
    width=$(get_tmux_option "@nunchux-popup-width" "60%")
    height=$(get_tmux_option "@nunchux-popup-height" "50%")

    # Bind key to open nunchux in a popup
    # Keys with "-" (like C-Space) bind without prefix, others require prefix
    if [[ $key == *"-"* ]]; then
        tmux bind-key -n "$key" display-popup -E -w "$width" -h "$height" "$NUNCHUCKS_CMD"
    else
        tmux bind-key "$key" display-popup -E -w "$width" -h "$height" "$NUNCHUCKS_CMD"
    fi
}

main

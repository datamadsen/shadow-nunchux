#!/usr/bin/env bash
# Visual test: per-app secondary_action override

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "Testing: per-app secondary_action override"
echo "  Global secondary_action = window"
echo "  App secondary_action = pane_right"
echo ""
echo "  1. Select hello app and press Ctrl-O"
echo "  2. Verify it opens in PANE RIGHT (app override wins)"
echo ""

run_nunchux_popup

echo ""
read -rp "Did Ctrl-O open hello in pane right (overriding window default)? [Y/n] " answer </dev/tty
[[ -z "$answer" || "$answer" =~ ^[Yy] ]] && pass "per-app secondary_action override works" || fail "per-app secondary_action override broken"

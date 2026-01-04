#!/usr/bin/env bash
# Visual test: window action

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "Testing: window action"
echo "  1. Select hello app and press Enter"
echo "  2. Verify it opens in a new WINDOW (check tmux tab bar)"
echo ""

run_nunchux_popup

echo ""
read -rp "Did hello open in a new window? [Y/n] " answer </dev/tty
[[ -z "$answer" || "$answer" =~ ^[Yy] ]] && pass "window action works" || fail "window action broken"

#!/usr/bin/env bash
# Visual test: window_key direct shortcut

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "Testing: window_key (Ctrl-W)"
echo "  1. Select hello app"
echo "  2. Press Ctrl-W (not Enter)"
echo "  3. Verify it opens in a WINDOW"
echo ""

run_nunchux_popup

echo ""
read -rp "Did Ctrl-W open hello in a window? [Y/n] " answer </dev/tty
[[ -z "$answer" || "$answer" =~ ^[Yy] ]] && pass "window_key works" || fail "window_key broken"

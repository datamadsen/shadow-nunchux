#!/usr/bin/env bash
# Visual test: popup_key direct shortcut

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "Testing: popup_key (Ctrl-P)"
echo "  1. Select hello app"
echo "  2. Press Ctrl-P (not Enter)"
echo "  3. Verify it opens in a POPUP"
echo ""

run_nunchux_popup

echo ""
read -rp "Did Ctrl-P open hello in a popup? [Y/n] " answer </dev/tty
[[ -z "$answer" || "$answer" =~ ^[Yy] ]] && pass "popup_key works" || fail "popup_key broken"

#!/usr/bin/env bash
# Visual test: popup action

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "Testing: popup action"
echo "  1. Select hello app and press Enter"
echo "  2. Verify it opens in a POPUP overlay (not a window)"
echo ""

run_nunchux_popup

echo ""
read -rp "Did hello open in a popup? [Y/n] " answer </dev/tty
[[ -z "$answer" || "$answer" =~ ^[Yy] ]] && pass "popup action works" || fail "popup action broken"

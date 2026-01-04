#!/usr/bin/env bash
# Visual test: custom secondary key

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "Testing: custom secondary key (Ctrl-S)"
echo "  1. Select hello app"
echo "  2. Press Ctrl-S (NOT Ctrl-O)"
echo "  3. Verify it opens in a WINDOW"
echo ""

run_nunchux_popup

echo ""
read -rp "Did Ctrl-S open hello in a window? [Y/n] " answer </dev/tty
[[ -z "$answer" || "$answer" =~ ^[Yy] ]] && pass "custom secondary_key works" || fail "custom secondary_key broken"

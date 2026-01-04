#!/usr/bin/env bash
# Visual test: secondary key default

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "Testing: secondary key (default Ctrl-O)"
echo "  1. Select hello app"
echo "  2. Press Ctrl-O (not Enter)"
echo "  3. Verify it opens in a WINDOW (secondary_action)"
echo ""

run_nunchux_popup

echo ""
read -rp "Did Ctrl-O open hello in a window? [Y/n] " answer </dev/tty
[[ -z "$answer" || "$answer" =~ ^[Yy] ]] && pass "secondary key works" || fail "secondary key broken"

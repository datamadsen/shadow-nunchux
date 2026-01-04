#!/usr/bin/env bash
# Visual test: action menu with default key

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "Testing: action menu (default ctrl-j)"
echo "  1. Select hello app"
echo "  2. Press ctrl-j"
echo "  3. Verify action picker appears with all 7 actions"
echo ""

run_nunchux_popup

echo ""
read -rp "Did ctrl-j show the action menu? [Y/n] " answer </dev/tty
[[ -z "$answer" || "$answer" =~ ^[Yy] ]] && pass "action menu works" || fail "action menu broken"

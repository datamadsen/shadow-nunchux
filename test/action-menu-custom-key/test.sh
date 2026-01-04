#!/usr/bin/env bash
# Visual test: action menu with custom key

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "Testing: action menu (custom key ctrl-a)"
echo "  1. Select hello app"
echo "  2. Press ctrl-a (NOT ctrl-j)"
echo "  3. Verify action picker appears"
echo ""

run_nunchux_popup

echo ""
read -rp "Did ctrl-a show the action menu? [Y/n] " answer </dev/tty
[[ -z "$answer" || "$answer" =~ ^[Yy] ]] && pass "custom action_menu_key works" || fail "custom action_menu_key broken"

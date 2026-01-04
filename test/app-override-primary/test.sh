#!/usr/bin/env bash
# Visual test: per-app primary_action override

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "Testing: per-app primary_action override"
echo "  Global primary_action = popup"
echo "  App primary_action = window"
echo ""
echo "  1. Select hello app and press Enter"
echo "  2. Verify it opens in WINDOW (app override wins)"
echo ""

run_nunchux_popup

echo ""
read -rp "Did hello open in window (overriding popup default)? [Y/n] " answer </dev/tty
[[ -z "$answer" || "$answer" =~ ^[Yy] ]] && pass "per-app primary_action override works" || fail "per-app primary_action override broken"

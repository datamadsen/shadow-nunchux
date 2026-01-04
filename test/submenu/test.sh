#!/usr/bin/env bash
# Test: Submenus with nested apps (automated)
# Verifies menu definitions and child apps work

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "(automated - checking menu output)"
menu=$(get_menu)

if echo "$menu" | grep -q "system"; then
  pass "submenu appears in main menu"
else
  fail "submenu not found in menu"
fi

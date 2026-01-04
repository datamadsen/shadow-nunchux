#!/usr/bin/env bash
# Test: App shortcuts (automated)
# Verifies shortcut= key bindings appear in menu

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "(automated - checking menu output)"
menu=$(get_menu)

if echo "$menu" | grep -q "ctrl-h" && echo "$menu" | grep -q "ctrl-b"; then
  pass "shortcuts appear in menu"
else
  fail "shortcuts not visible in menu"
fi

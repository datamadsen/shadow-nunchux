#!/usr/bin/env bash
# Test: NPM taskrunner (automated)
# Verifies npm taskrunner items appear in menu

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "(automated - checking menu output)"
menu=$(get_menu)

if echo "$menu" | grep -q "npm"; then
  pass "taskrunner items appear in menu"
else
  fail "taskrunner items missing from menu"
fi

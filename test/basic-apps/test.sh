#!/usr/bin/env bash
# Test: Basic app definitions (automated)
# Verifies simple apps with cmd and desc work correctly

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "(automated - checking menu output)"
menu=$(get_menu)

if echo "$menu" | grep -q "hello" && echo "$menu" | grep -q "btop"; then
  pass "basic apps appear in menu"
else
  fail "apps missing from menu"
fi

#!/usr/bin/env bash
# Test: Environment test (automated)
# Verifies config parses correctly

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "(automated - checking menu output)"
menu=$(get_menu)

if echo "$menu" | grep -q "env"; then
  pass "config parses correctly"
else
  fail "config parse error"
fi

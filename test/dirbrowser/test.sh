#!/usr/bin/env bash
# Test: Directory browser (automated)
# Verifies dirbrowser with various options

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "(automated - checking menu output)"
menu=$(get_menu)

if echo "$menu" | grep -q "dirbrowser:"; then
  pass "dirbrowser appears in menu"
else
  fail "dirbrowser not found"
fi

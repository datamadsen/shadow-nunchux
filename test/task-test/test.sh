#!/usr/bin/env bash
# Test: Task taskrunner (automated)
# Verifies task taskrunner items appear in menu

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "(automated - checking menu output)"
menu=$(get_menu)

if echo "$menu" | grep -q "task"; then
  pass "taskrunner items appear in menu"
else
  fail "taskrunner items missing from menu"
fi

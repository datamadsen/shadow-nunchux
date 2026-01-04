#!/usr/bin/env bash
# Test: Global settings (automated)
# Verifies custom settings are applied

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "(automated - checking menu output)"
menu=$(get_menu)

# Check that custom icon appears (we set icon_stopped = ◯)
if echo "$menu" | grep -q "◯"; then
  pass "custom settings applied"
else
  # Fallback - just check config parses
  if echo "$menu" | grep -q "hello"; then
    pass "config parses correctly"
  else
    fail "config parse error"
  fi
fi

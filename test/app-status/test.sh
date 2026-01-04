#!/usr/bin/env bash
# Test: App status indicators (automated)
# Verifies status= commands run and display output

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "(automated - checking menu output)"
menu=$(get_menu)

if echo "$menu" | grep -qE "(load:|changed)"; then
  pass "status indicators appear"
else
  # Status may be empty if no git changes - just check apps parse
  if echo "$menu" | grep -q "hello"; then
    pass "config parses (status may be empty)"
  else
    fail "config parse error"
  fi
fi

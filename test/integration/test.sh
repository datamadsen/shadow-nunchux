#!/usr/bin/env bash
# Test: Integration (automated)
# Verifies apps, menus, dirbrowsers, and taskrunners all work together

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "(automated - checking menu output)"
menu=$(get_menu)
errors=0

# Check for apps
echo "$menu" | grep -q "hello" || ((errors++)) || true
echo "$menu" | grep -q "lazygit" || ((errors++)) || true

# Check for menu
echo "$menu" | grep -q "system" || ((errors++)) || true

# Check for dirbrowser
echo "$menu" | grep -q "config" || ((errors++)) || true

if [[ $errors -eq 0 ]]; then
  pass "apps, menus, and dirbrowsers appear"
else
  fail "some items missing ($errors)"
fi

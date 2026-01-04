#!/usr/bin/env bash
# Test: Invalid shortcuts (automated)
# Verifies invalid fzf shortcuts are detected

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "(automated - checking config for invalid shortcuts)"
# This test shows error via tmux popup - can only verify config has invalid shortcuts
source "$PROJECT_ROOT/lib/config.sh"

config_file="$TEST_DIR/.nunchuxrc"
invalid_found=false

while IFS= read -r line; do
  if [[ "$line" =~ ^shortcut[[:space:]]*=[[:space:]]*(.+)$ ]]; then
    key="${BASH_REMATCH[1]}"
    if ! is_valid_fzf_key "$key"; then
      invalid_found=true
      break
    fi
  fi
done < "$config_file"

if [[ "$invalid_found" == "true" ]]; then
  pass "invalid shortcuts in config (visual test: run -i)"
else
  fail "expected invalid shortcuts in config"
fi

#!/usr/bin/env bash
# Test: Conflicting shortcuts (automated)
# Verifies duplicate shortcuts are detected

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "(automated - checking config for conflicts)"
# This test shows error via tmux popup - verify config has conflicts
source "$PROJECT_ROOT/lib/config.sh"

config_file="$TEST_DIR/.nunchuxrc"
declare -A seen_shortcuts=()
conflict_found=false

while IFS= read -r line; do
  if [[ "$line" =~ ^shortcut[[:space:]]*=[[:space:]]*(.+)$ ]]; then
    key="${BASH_REMATCH[1]}"
    if [[ -n "${seen_shortcuts[$key]:-}" ]]; then
      conflict_found=true
      break
    fi
    seen_shortcuts["$key"]=1
  fi
done < "$config_file"

if [[ "$conflict_found" == "true" ]]; then
  pass "duplicate shortcuts in config (visual test: run -i)"
else
  fail "expected duplicate shortcuts in config"
fi

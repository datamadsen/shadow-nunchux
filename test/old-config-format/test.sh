#!/usr/bin/env bash
# Test: Old config format (automated)
# Verifies old format (without type: prefix) is detected for migration

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "(automated - checking config format)"
source "$PROJECT_ROOT/lib/config.sh"

config_file="$TEST_DIR/.nunchuxrc"

if is_old_config_format "$config_file"; then
  pass "old format correctly detected"
else
  fail "old format not detected"
fi

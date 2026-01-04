#!/usr/bin/env bash
# Test: Old order format (automated)
# Verifies old per-item order= syntax is detected for migration

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "(automated - checking config format)"
source "$PROJECT_ROOT/lib/config.sh"

config_file="$TEST_DIR/.nunchuxrc"

if needs_order_migration "$config_file"; then
  pass "order migration correctly detected"
else
  fail "order migration not detected"
fi

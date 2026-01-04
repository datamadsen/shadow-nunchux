#!/usr/bin/env bash
# Automated test: pane_right action
# Verifies app opens in a pane to the right of the current one

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "Testing: pane_right action"
echo "  1. Press Enter to select hello app"
echo "  2. Test will automatically verify pane position"
echo ""

# Capture state BEFORE
original_pane=$(tmux display-message -p "#{pane_id}")
original_right=$(tmux display-message -p "#{pane_right}")
pane_count_before=$(tmux list-panes | wc -l)

echo "Initial state:"
echo "  Pane: $original_pane"
echo "  Right position: $original_right"
echo "  Pane count: $pane_count_before"
echo ""

run_nunchux_popup

# Check immediately (new pane has ~1 sec before it closes)
sleep 0.1

# Capture state AFTER
pane_count_after=$(tmux list-panes | wc -l)
new_right=$(tmux display-message -t "$original_pane" -p "#{pane_right}")

echo ""
echo "After state:"
echo "  Pane count: $pane_count_after"
echo "  Original pane right: $new_right (was $original_right)"
echo ""

# Check 1: New pane was created
if [[ "$pane_count_after" -gt "$pane_count_before" ]]; then
  echo "  [OK] New pane created ($pane_count_before -> $pane_count_after)"
else
  fail "No new pane created (count: $pane_count_before -> $pane_count_after)"
fi

# Check 2: Original pane shrunk from right (right decreased) = new pane is to the right
if [[ "$new_right" -lt "$original_right" ]]; then
  pass "pane_right works: original pane right moved from $original_right to $new_right"
else
  fail "Pane not right: original right stayed at $original_right (expected decrease)"
fi

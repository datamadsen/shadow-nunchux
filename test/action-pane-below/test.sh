#!/usr/bin/env bash
# Automated test: pane_below action
# Verifies app opens in a pane below the current one

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "Testing: pane_below action"
echo "  1. Press Enter to select hello app"
echo "  2. Test will automatically verify pane position"
echo ""

# Capture state BEFORE
original_pane=$(tmux display-message -p "#{pane_id}")
original_bottom=$(tmux display-message -p "#{pane_bottom}")
pane_count_before=$(tmux list-panes | wc -l)

echo "Initial state:"
echo "  Pane: $original_pane"
echo "  Bottom position: $original_bottom"
echo "  Pane count: $pane_count_before"
echo ""

run_nunchux_popup

# Check immediately (new pane has ~1 sec before it closes)
sleep 0.1

# Capture state AFTER
pane_count_after=$(tmux list-panes | wc -l)
new_bottom=$(tmux display-message -t "$original_pane" -p "#{pane_bottom}")

echo ""
echo "After state:"
echo "  Pane count: $pane_count_after"
echo "  Original pane bottom: $new_bottom (was $original_bottom)"
echo ""

# Check 1: New pane was created
if [[ "$pane_count_after" -gt "$pane_count_before" ]]; then
  echo "  [OK] New pane created ($pane_count_before -> $pane_count_after)"
else
  fail "No new pane created (count: $pane_count_before -> $pane_count_after)"
fi

# Check 2: Original pane shrunk from bottom (bottom decreased) = new pane is below
if [[ "$new_bottom" -lt "$original_bottom" ]]; then
  pass "pane_below works: original pane bottom moved from $original_bottom to $new_bottom"
else
  fail "Pane not below: original bottom stayed at $original_bottom (expected decrease)"
fi

#!/usr/bin/env bash
# Automated test: pane_left action
# Verifies app opens in a pane to the left of the current one

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "Testing: pane_left action"
echo "  1. Press Enter to select hello app"
echo "  2. Test will automatically verify pane position"
echo ""

# Capture state BEFORE
original_pane=$(tmux display-message -p "#{pane_id}")
original_left=$(tmux display-message -p "#{pane_left}")
pane_count_before=$(tmux list-panes | wc -l)

echo "Initial state:"
echo "  Pane: $original_pane"
echo "  Left position: $original_left"
echo "  Pane count: $pane_count_before"
echo ""

run_nunchux_popup

# Check immediately (new pane has ~1 sec before it closes)
sleep 0.1

# Capture state AFTER
pane_count_after=$(tmux list-panes | wc -l)
new_left=$(tmux display-message -t "$original_pane" -p "#{pane_left}")

echo ""
echo "After state:"
echo "  Pane count: $pane_count_after"
echo "  Original pane left: $new_left (was $original_left)"
echo ""

# Check 1: New pane was created
if [[ "$pane_count_after" -gt "$pane_count_before" ]]; then
  echo "  [OK] New pane created ($pane_count_before -> $pane_count_after)"
else
  fail "No new pane created (count: $pane_count_before -> $pane_count_after)"
fi

# Check 2: Original pane moved right (left increased) = new pane is to the left
if [[ "$new_left" -gt "$original_left" ]]; then
  pass "pane_left works: original pane left moved from $original_left to $new_left"
else
  fail "Pane not left: original left stayed at $original_left (expected increase)"
fi

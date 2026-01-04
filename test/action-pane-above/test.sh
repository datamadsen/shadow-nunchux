#!/usr/bin/env bash
# Automated test: pane_above action
# Verifies app opens in a pane above the current one

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "Testing: pane_above action"
echo "  1. Press Enter to select hello app"
echo "  2. Test will automatically verify pane position"
echo ""

# Capture state BEFORE
original_pane=$(tmux display-message -p "#{pane_id}")
original_top=$(tmux display-message -p "#{pane_top}")
pane_count_before=$(tmux list-panes | wc -l)

echo "Initial state:"
echo "  Pane: $original_pane"
echo "  Top position: $original_top"
echo "  Pane count: $pane_count_before"
echo ""

run_nunchux_popup

# Check immediately (new pane has ~1 sec before it closes)
sleep 0.1

# Capture state AFTER
pane_count_after=$(tmux list-panes | wc -l)
new_top=$(tmux display-message -t "$original_pane" -p "#{pane_top}")

echo ""
echo "After state:"
echo "  Pane count: $pane_count_after"
echo "  Original pane top: $new_top (was $original_top)"
echo ""

# Check 1: New pane was created
if [[ "$pane_count_after" -gt "$pane_count_before" ]]; then
  echo "  [OK] New pane created ($pane_count_before -> $pane_count_after)"
else
  fail "No new pane created (count: $pane_count_before -> $pane_count_after)"
fi

# Check 2: Original pane moved down (top increased) = new pane is above
if [[ "$new_top" -gt "$original_top" ]]; then
  pass "pane_above works: original pane moved from top=$original_top to top=$new_top"
else
  fail "Pane not above: original top stayed at $original_top (expected increase)"
fi

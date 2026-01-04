#!/usr/bin/env bash
# Automated test: background_window action
# Verifies: new window created BUT focus stays on original window

source "${BASH_SOURCE%/*}/../test_helpers.sh"

echo "Testing: background_window action"
echo "  1. Press Enter to select hello"
echo "  2. Test will automatically verify background window behavior"
echo ""

# Capture state BEFORE
windows_before=$(tmux list-windows -F "#{window_index}:#{window_name}")
active_before=$(tmux display-message -p "#{window_index}")
window_count_before=$(echo "$windows_before" | wc -l)

echo "Initial state:"
echo "  Active window: $active_before"
echo "  Window count: $window_count_before"
echo ""

run_nunchux_popup

# Brief pause to let tmux finish window creation
sleep 0.3

# Capture state AFTER
windows_after=$(tmux list-windows -F "#{window_index}:#{window_name}")
active_after=$(tmux display-message -p "#{window_index}")
window_count_after=$(echo "$windows_after" | wc -l)

echo ""
echo "After state:"
echo "  Active window: $active_after"
echo "  Window count: $window_count_after"
echo ""

# Check 1: New window was created
if [[ "$window_count_after" -gt "$window_count_before" ]]; then
  echo "  [OK] New window created ($window_count_before -> $window_count_after)"
else
  fail "No new window created (count: $window_count_before -> $window_count_after)"
fi

# Check 2: New window contains hello
new_windows=$(comm -13 <(echo "$windows_before" | sort) <(echo "$windows_after" | sort))
if echo "$new_windows" | grep -qi "hello"; then
  echo "  [OK] New window is hello"
else
  echo "  [WARN] New window might not be hello: $new_windows"
fi

# Check 3: Focus stayed on original window (the key test!)
if [[ "$active_after" == "$active_before" ]]; then
  pass "background_window works: new window created, focus stayed on window $active_before"
else
  fail "Focus changed from window $active_before to $active_after (should stay same)"
fi

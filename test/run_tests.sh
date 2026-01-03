#!/usr/bin/env bash
#
# test/run_tests.sh - Simple test runner for nunchux
#
# Usage:
#   ./run_tests.sh           # Run all automated tests
#   ./run_tests.sh -i        # Interactive mode (fzf menu)
#   ./run_tests.sh <name>    # Run specific test folder
#

set -euo pipefail

# Determine script and project directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
NUNCHUX_BIN="$PROJECT_ROOT/bin/nunchux"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
DIM='\033[0;90m'
BOLD='\033[1m'
RESET='\033[0m'

# Counters
PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

# ============================================================================
# Output helpers
# ============================================================================

pass() {
  local name="$1"
  local msg="${2:-}"
  echo -e "${GREEN}[PASS]${RESET} ${BOLD}$name${RESET}${msg:+: $msg}"
  ((PASS_COUNT++)) || true
}

fail() {
  local name="$1"
  local msg="${2:-}"
  local detail="${3:-}"
  echo -e "${RED}[FAIL]${RESET} ${BOLD}$name${RESET}${msg:+: $msg}"
  [[ -n "$detail" ]] && echo -e "       ${DIM}$detail${RESET}"
  ((FAIL_COUNT++)) || true
}

skip() {
  local name="$1"
  local msg="${2:-}"
  echo -e "${YELLOW}[SKIP]${RESET} ${BOLD}$name${RESET}${msg:+: $msg}"
  ((SKIP_COUNT++)) || true
}

info() {
  echo -e "${CYAN}$1${RESET}"
}

# ============================================================================
# Test helpers
# ============================================================================

# Run nunchux with a test config
# Usage: run_nunchux <test_dir> [args...]
# Returns: exit code from nunchux
run_nunchux() {
  local test_dir="$1"
  shift
  local config_file="$test_dir/.nunchuxrc"
  [[ -f "$test_dir/config" ]] && config_file="$test_dir/config"

  # Run from test directory (important for taskrunners to detect files)
  (cd "$test_dir" && NUNCHUX_RC_FILE="$config_file" "$NUNCHUX_BIN" "$@" 2>&1)
}

# Check if menu output contains expected item
# Usage: menu_contains <test_dir> <pattern>
menu_contains() {
  local test_dir="$1"
  local pattern="$2"
  run_nunchux "$test_dir" --menu 2>/dev/null | grep -qE "$pattern"
}

# Get menu output
get_menu() {
  local test_dir="$1"
  run_nunchux "$test_dir" --menu 2>/dev/null
}

# ============================================================================
# Test definitions
# ============================================================================

# Test: just-test
test_just_test() {
  local name="just-test"
  local dir="$SCRIPT_DIR/$name"

  [[ ! -d "$dir" ]] && { skip "$name" "directory not found"; return; }

  local menu
  menu=$(get_menu "$dir" 2>&1) || true

  if echo "$menu" | grep -q "just"; then
    pass "$name" "taskrunner items appear in menu"
  else
    fail "$name" "taskrunner items missing from menu" "Output: ${menu:0:100}..."
  fi
}

# Test: npm-test
test_npm_test() {
  local name="npm-test"
  local dir="$SCRIPT_DIR/$name"

  [[ ! -d "$dir" ]] && { skip "$name" "directory not found"; return; }

  local menu
  menu=$(get_menu "$dir" 2>&1) || true

  if echo "$menu" | grep -q "npm"; then
    pass "$name" "taskrunner items appear in menu"
  else
    fail "$name" "taskrunner items missing from menu" "Output: ${menu:0:100}..."
  fi
}

# Test: task-test
test_task_test() {
  local name="task-test"
  local dir="$SCRIPT_DIR/$name"

  [[ ! -d "$dir" ]] && { skip "$name" "directory not found"; return; }

  local menu
  menu=$(get_menu "$dir" 2>&1) || true

  if echo "$menu" | grep -q "task"; then
    pass "$name" "taskrunner items appear in menu"
  else
    fail "$name" "taskrunner items missing from menu" "Output: ${menu:0:100}..."
  fi
}

# Test: all-plugins
test_all_plugins() {
  local name="all-plugins"
  local dir="$SCRIPT_DIR/$name"

  [[ ! -d "$dir" ]] && { skip "$name" "directory not found"; return; }

  local menu
  menu=$(get_menu "$dir" 2>&1) || true
  local errors=0

  # Check for apps
  echo "$menu" | grep -q "htop" || { ((errors++)) || true; }
  echo "$menu" | grep -q "lazygit" || { ((errors++)) || true; }

  # Check for menu
  echo "$menu" | grep -q "system" || { ((errors++)) || true; }

  # Check for dirbrowser
  echo "$menu" | grep -q "config" || { ((errors++)) || true; }

  if [[ $errors -eq 0 ]]; then
    pass "$name" "apps, menus, and dirbrowsers appear"
  else
    fail "$name" "some items missing ($errors)" "Check: htop, lazygit, system, config"
  fi
}

# Test: invalid-shortcut
test_invalid_shortcut() {
  local name="invalid-shortcut"
  local dir="$SCRIPT_DIR/$name"

  [[ ! -d "$dir" ]] && { skip "$name" "directory not found"; return; }

  # This test shows error via tmux popup - can only verify config parsing
  # Use lib/config.sh directly to check shortcut validation
  source "$PROJECT_ROOT/lib/config.sh"

  local config_file="$dir/.nunchuxrc"
  local invalid_found=false

  # Parse config to get shortcuts, then validate them
  while IFS= read -r line; do
    if [[ "$line" =~ ^shortcut[[:space:]]*=[[:space:]]*(.+)$ ]]; then
      local key="${BASH_REMATCH[1]}"
      if ! is_valid_fzf_key "$key"; then
        invalid_found=true
        break
      fi
    fi
  done < "$config_file"

  if [[ "$invalid_found" == "true" ]]; then
    pass "$name" "invalid shortcuts in config (visual test: run -i)"
  else
    fail "$name" "expected invalid shortcuts in config"
  fi
}

# Test: conflicting-shortcuts
test_conflicting_shortcuts() {
  local name="conflicting-shortcuts"
  local dir="$SCRIPT_DIR/$name"

  [[ ! -d "$dir" ]] && { skip "$name" "directory not found"; return; }

  # This test shows error via tmux popup - verify config has conflicts
  source "$PROJECT_ROOT/lib/config.sh"

  local config_file="$dir/.nunchuxrc"
  local -A seen_shortcuts=()
  local conflict_found=false

  while IFS= read -r line; do
    if [[ "$line" =~ ^shortcut[[:space:]]*=[[:space:]]*(.+)$ ]]; then
      local key="${BASH_REMATCH[1]}"
      if [[ -n "${seen_shortcuts[$key]:-}" ]]; then
        conflict_found=true
        break
      fi
      seen_shortcuts["$key"]=1
    fi
  done < "$config_file"

  if [[ "$conflict_found" == "true" ]]; then
    pass "$name" "duplicate shortcuts in config (visual test: run -i)"
  else
    fail "$name" "expected duplicate shortcuts in config"
  fi
}

# Test: old-config-format
test_old_config_format() {
  local name="old-config-format"
  local dir="$SCRIPT_DIR/$name"

  [[ ! -d "$dir" ]] && { skip "$name" "directory not found"; return; }

  # Just check that config is recognized as needing migration
  local config_file="$dir/.nunchuxrc"

  # Source the config check function
  source "$PROJECT_ROOT/lib/config.sh"

  if is_old_config_format "$config_file"; then
    pass "$name" "old format correctly detected"
  else
    fail "$name" "old format not detected"
  fi
}

# Test: old-order-format
test_old_order_format() {
  local name="old-order-format"
  local dir="$SCRIPT_DIR/$name"

  [[ ! -d "$dir" ]] && { skip "$name" "directory not found"; return; }

  local config_file="$dir/.nunchuxrc"

  source "$PROJECT_ROOT/lib/config.sh"

  if needs_order_migration "$config_file"; then
    pass "$name" "order migration correctly detected"
  else
    fail "$name" "order migration not detected"
  fi
}

# Test: env-test (basic check)
test_env_test() {
  local name="env-test"
  local dir="$SCRIPT_DIR/$name"

  [[ ! -d "$dir" ]] && { skip "$name" "directory not found"; return; }

  # Just verify the config parses
  local menu
  menu=$(get_menu "$dir" 2>&1) || true

  if echo "$menu" | grep -q "env"; then
    pass "$name" "config parses correctly"
  else
    fail "$name" "config parse error" "Output: ${menu:0:100}..."
  fi
}

# ============================================================================
# Test runner
# ============================================================================

# List of all tests
ALL_TESTS=(
  test_just_test
  test_npm_test
  test_task_test
  test_all_plugins
  test_invalid_shortcut
  test_conflicting_shortcuts
  test_old_config_format
  test_old_order_format
  test_env_test
)

# Run all tests
run_all() {
  echo ""
  info "Running tests..."
  echo ""

  for test_func in "${ALL_TESTS[@]}"; do
    "$test_func"
  done

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  local total=$((PASS_COUNT + FAIL_COUNT + SKIP_COUNT))
  echo -e "${BOLD}$total tests:${RESET} ${GREEN}$PASS_COUNT passed${RESET}, ${RED}$FAIL_COUNT failed${RESET}, ${YELLOW}$SKIP_COUNT skipped${RESET}"
  echo ""

  [[ $FAIL_COUNT -gt 0 ]] && return 1
  return 0
}

# Run a specific test by folder name
run_one() {
  local name="$1"
  local func="test_${name//-/_}"

  if declare -f "$func" >/dev/null 2>&1; then
    echo ""
    info "Running test: $name"
    echo ""
    "$func"
    echo ""
    [[ $FAIL_COUNT -gt 0 ]] && return 1
    return 0
  else
    echo "Unknown test: $name" >&2
    echo "Available tests:" >&2
    for t in "${ALL_TESTS[@]}"; do
      echo "  ${t#test_}" | tr '_' '-' >&2
    done
    return 1
  fi
}

# Interactive mode with fzf
run_interactive() {
  local tests=()
  for t in "${ALL_TESTS[@]}"; do
    tests+=("$(echo "${t#test_}" | tr '_' '-')")
  done
  tests+=("visual: all-plugins")
  tests+=("visual: just-test")
  tests+=("visual: npm-test")
  tests+=("visual: task-test")

  local selection
  selection=$(printf '%s\n' "${tests[@]}" | fzf --prompt="Select test > " --height=40%)

  [[ -z "$selection" ]] && return 0

  if [[ "$selection" == visual:* ]]; then
    local folder="${selection#visual: }"
    local dir="$SCRIPT_DIR/$folder"
    local config_file="$dir/.nunchuxrc"
    [[ -f "$dir/config" ]] && config_file="$dir/config"

    echo ""
    info "Launching nunchux in $folder..."
    info "Press Esc to exit, then mark pass/fail"
    echo ""

    NUNCHUX_RC_FILE="$config_file" "$NUNCHUX_BIN" || true

    echo ""
    read -rp "Did the test pass? [y/n/s] " answer
    case "$answer" in
      y|Y) pass "$folder" "visual inspection passed" ;;
      n|N) fail "$folder" "visual inspection failed" ;;
      *) skip "$folder" "skipped" ;;
    esac
  else
    run_one "$selection"
  fi
}

# ============================================================================
# Main
# ============================================================================

usage() {
  cat <<EOF
Usage: $(basename "$0") [options] [test-name]

Options:
  -i, --interactive    Interactive mode (fzf menu)
  -h, --help           Show this help

Examples:
  $(basename "$0")              Run all automated tests
  $(basename "$0") just-test    Run just the just-test
  $(basename "$0") -i           Pick test interactively
EOF
}

main() {
  case "${1:-}" in
    -i|--interactive)
      run_interactive
      ;;
    -h|--help)
      usage
      ;;
    "")
      run_all
      ;;
    *)
      run_one "$1"
      ;;
  esac
}

main "$@"

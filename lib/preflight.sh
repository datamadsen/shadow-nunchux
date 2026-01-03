#!/usr/bin/env bash
#
# lib/preflight.sh - Pre-flight dependency checks for nunchux
#

# Guard against double-sourcing
[[ -n "${NUNCHUX_LIB_PREFLIGHT_LOADED:-}" ]] && return
NUNCHUX_LIB_PREFLIGHT_LOADED=1

# Minimum fzf version for Unix socket support
FZF_MIN_VERSION_MAJOR=0
FZF_MIN_VERSION_MINOR=45

# Check if fzf version meets minimum requirements
# Returns: 0 if OK, 1 if missing, 2 if version too old
# Outputs: version string if too old (for error message)
check_fzf_version_preflight() {
  command -v fzf &>/dev/null || return 1

  local version major minor
  version=$(fzf --version 2>/dev/null | head -1 | grep -oE '^[0-9]+\.[0-9]+' || echo "0.0")
  major="${version%%.*}"
  minor="${version#*.}"
  minor="${minor%%.*}"

  if [[ "$major" -gt $FZF_MIN_VERSION_MAJOR ]] ||
     [[ "$major" -eq $FZF_MIN_VERSION_MAJOR && "$minor" -ge $FZF_MIN_VERSION_MINOR ]]; then
    return 0
  fi

  echo "$version"
  return 2
}

# Run all pre-flight dependency checks
# Usage: run_preflight_checks FAILURES_ARRAY
# Returns 0 if all checks pass, 1 if any fail
# Populates nameref array with failure details
run_preflight_checks() {
  local -n _failures=$1

  # Check tmux binary exists
  if ! command -v tmux &>/dev/null; then
    _failures["tmux"]="tmux is required - install from your package manager"
  fi

  # Check curl binary exists (needed for fzf hot-swap)
  if ! command -v curl &>/dev/null; then
    _failures["curl"]="curl is required for menu hot-swap"
  fi

  # Check fzf with version requirement
  local fzf_version
  fzf_version=$(check_fzf_version_preflight)
  local fzf_status=$?

  case $fzf_status in
    1) _failures["fzf"]="fzf is not installed - get it from https://github.com/junegunn/fzf" ;;
    2) _failures["fzf"]="fzf $fzf_version is too old (need ${FZF_MIN_VERSION_MAJOR}.${FZF_MIN_VERSION_MINOR}+)" ;;
  esac

  # Check running inside tmux session
  if [[ -z "${TMUX:-}" ]]; then
    _failures["tmux_session"]="Must be run inside a tmux session"
  fi

  # Return success if no failures
  [[ ${#_failures[@]} -eq 0 ]]
}

# vim: ft=bash ts=2 sw=2 et

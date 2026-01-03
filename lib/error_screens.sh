#!/usr/bin/env bash
#
# lib/error_screens.sh - Error screens for nunchux setup
#

# Guard against double-sourcing
[[ -n "${NUNCHUX_LIB_ERROR_SCREENS_LOADED:-}" ]] && return
NUNCHUX_LIB_ERROR_SCREENS_LOADED=1

# Show dependency error screen
# Usage: show_setup_error "dependency" FAILURES_ARRAY
show_setup_error() {
  local error_type="$1"
  local -n _details=$2

  [[ "$error_type" != "dependency" ]] && return

  echo ""
  echo -e "\033[1;31mMissing Dependencies\033[0m"
  echo ""
  for dep in "${!_details[@]}"; do
    echo "  - ${_details[$dep]}"
  done
  echo ""
  echo "Install the missing dependencies and try again."
  echo ""
  echo "Press any key to exit..."
  read -rsn1
  exit 1
}

# vim: ft=bash ts=2 sw=2 et

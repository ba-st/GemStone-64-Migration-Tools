#!/usr/bin/env bash
readonly ANSI_BOLD="\\033[1m"
readonly ANSI_RED="\\033[31m"
readonly ANSI_RESET="\\033[0m"

function print_error() {
  if [ -t 1 ]; then
    printf "${ANSI_BOLD}${ANSI_RED}%s${ANSI_RESET}\\n" "$1" 1>&2
  else
    echo "$1" 1>&2
  fi
}

message=$1
output=/opt/gemstone/logs/loading-rowan-projects.log

if [ "$(grep -c "$message" "$output")" -eq 0 ]; then
  print_error "Expected output: '$message' not found in the migration log"
  print_error "Output contents:"
  cat "$output"
  exit 1
fi

exit 0

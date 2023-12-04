#!/usr/bin/env bash

message=$1
output=/opt/gemstone/logs/loading-rowan-projects.log

if [ "$(grep -c "$message" "$output")" -eq 0 ]; then
  print_error "Expected output: '$message' not found in the migration log"
  print_info "Output contents:"
  cat "$output"
  exit 1
fi

exit 0

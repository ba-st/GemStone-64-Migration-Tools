#!/usr/bin/env bash

message=$1
output=/opt/gemstone/logs/loading-rowan-projects.log

if [ "$(grep -c "$message" "$output")" -eq 0 ]; then
  echo "Expected output: '$message' not found in the migration log"
  echo "Output contents:"
  cat "$output"
  exit 1
fi

exit 0

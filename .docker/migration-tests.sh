#!/usr/bin/env bash

readonly ANSI_BOLD="\\033[1m"
readonly ANSI_RED="\\033[31m"
readonly ANSI_GREEN="\\033[32m"
readonly ANSI_BLUE="\\033[34m"
readonly ANSI_RESET="\\033[0m"

function print_info() {
  if [ -t 1 ]; then
    printf "${ANSI_BOLD}${ANSI_BLUE}%s${ANSI_RESET}\\n" "$1"
  else
    echo "$1"
  fi
}

function print_success() {
  if [ -t 1 ]; then
    printf "${ANSI_BOLD}${ANSI_GREEN}%s${ANSI_RESET}\\n" "$1"
  else
    echo "$1"
  fi
}

function print_error() {
  if [ -t 1 ]; then
    printf "${ANSI_BOLD}${ANSI_RED}%s${ANSI_RESET}\\n" "$1" 1>&2
  else
    echo "$1" 1>&2
  fi
}

set -e

print_info "Starting stone"

docker run --rm --detach --name gs64-migration \
  -e TZ="America/Argentina/Buenos_Aires" \
  --volume="$PWD":/opt/gemstone/projects/GemStone-64-Migration-Tools:ro \
  ghcr.io/ba-st/gs64-rowan:v3.7.0

sleep 1

print_info "Stopping stone"
docker stop gs64-migration

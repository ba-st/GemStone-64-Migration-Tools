#!/usr/bin/env bash

readonly ANSI_BOLD="\\033[1m"
readonly ANSI_RED="\\033[31m"
readonly ANSI_GREEN="\\033[32m"
readonly ANSI_RESET="\\033[0m"

function print_error() {
  if [ -t 1 ]; then
    printf "${ANSI_BOLD}${ANSI_RED}%s${ANSI_RESET}\\n" "$1" 1>&2
  else
    echo "$1" 1>&2
  fi
}

function print_success() {
  if [ -t 1 ]; then
    printf "${ANSI_BOLD}${ANSI_GREEN}%s${ANSI_RESET}\\n" "$1"
  else
    echo "$1"
  fi
}

status=$(topaz -i -q <<EOF
set gemstone gs64stone user SystemUser pass ${GS64_SYSTEM_USER_PASSWORD}
iferror exit 1
login
expectvalue true
run
  Rowan platform instanceMigrator migrationWasSuccessfull
%
logout
exit 0
EOF
)

if [ "$status" -eq 0 ];then
  print_success "Migration ended successfully"
  exit 0
else
  print_error "####################"
  print_error " Migration failed"
  print_error "####################"
  print_info "Details of the process:\n"
  cat /opt/gemstone/logs/loading-rowan-projects.log
  exit 1
fi
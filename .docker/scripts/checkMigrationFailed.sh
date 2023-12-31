#!/usr/bin/env bash

readonly ANSI_BOLD="\\033[1m"
readonly ANSI_RED="\\033[31m"
readonly ANSI_GREEN="\\033[32m"
readonly ANSI_BLUE="\\033[34m"
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

function print_info() {
  if [ -t 1 ]; then
    printf "${ANSI_BOLD}${ANSI_BLUE}%s${ANSI_RESET}\\n" "$1"
  else
    echo "$1"
  fi
}

if topaz -i -q <<EOF
set gemstone gs64stone user SystemUser pass ${GS64_SYSTEM_USER_PASSWORD}
iferror exit 1
login
expectvalue false
run
  Rowan platform instanceMigrator migrationWasSuccessful
%
logout
exit 0
EOF
then
  print_success "Migration failed as expected"
  print_info "Details of the process:\n"
  cat /opt/gemstone/logs/loading-rowan-projects.log
  exit 0
else
  print_error "##########################################"
  print_error " Migration succeded when expected to fail"
  print_error "##########################################"
  cat /opt/gemstone/logs/loading-rowan-projects.log  
  exit 1
fi

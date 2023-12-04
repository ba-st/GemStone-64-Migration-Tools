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

function executeInDocker() {
  docker exec gs64-migration "$@"
}

function assertMigrationLogIncludes() {
  executeInDocker ./scripts/assertMigrationLogIncludesMessage.sh "$1"
}

set -e

print_info "Starting stone"

docker pull ghcr.io/ba-st/gs64-rowan:v3.7.0

docker run --rm --detach --name gs64-migration \
  -e TZ="America/Argentina/Buenos_Aires" \
  --cap-add=SYS_RESOURCE \
  --volume="$PWD":/opt/gemstone/projects/GemStone-64-Migration-Tools:ro \
  --volume="$PWD"/.docker/scripts:/opt/gemstone/scripts:ro \
  ghcr.io/ba-st/gs64-rowan:v3.7.0

sleep 1

print_info "Loading Migration Tools"

executeInDocker ./load-rowan-project.sh \
  GemStone-64-Migration-Tools \
  GemStone-64-Migration-Tools-Deployment

print_info "Loading Migration Examples base version"

executeInDocker git clone -b base \
  https://github.com/ba-st/GS64-Migration-Examples.git \
  /opt/gemstone/projects/GS64-Migration-Examples

executeInDocker ./load-rowan-project.sh \
  GS64-Migration-Examples \
  GS64-Migration-Examples

print_info "Configuring instance migrator"

executeInDocker ./scripts/installInstanceMigrator.sh

print_info "Loading Migration Examples successful_migration version"

docker exec --workdir /opt/gemstone/projects/GS64-Migration-Examples \
  gs64-migration \
  git checkout successful_migration

executeInDocker ./load-rowan-project.sh \
  GS64-Migration-Examples \
  GS64-Migration-Examples

"Checking migration result"

executeInDocker ./checkMigrationWasSuccessful.sh

print_info "Stopping stone"
docker stop gs64-migration

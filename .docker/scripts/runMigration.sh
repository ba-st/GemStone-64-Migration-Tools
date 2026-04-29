#!/usr/bin/env bash

topaz -i -q <<EOF >> "${GEMSTONE_LOG_DIR}/loading-rowan-projects.log"

set gemstone gs64stone user SystemUser pass ${GS64_SYSTEM_USER_PASSWORD}
iferror exit 1
login
run
  Rowan platform instanceMigrator runMigration
%
logout
exit 0
EOF

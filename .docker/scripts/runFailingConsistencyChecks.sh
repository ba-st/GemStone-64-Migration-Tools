#!/usr/bin/env bash

topaz -i -q <<EOF > "${GEMSTONE_LOG_DIR}/consistency-checks.log"
set gemstone gs64stone user SystemUser pass ${GS64_SYSTEM_USER_PASSWORD}
iferror exit 1
login
expectvalue false
run
  Rowan platform instanceMigrator runConsistencyChecks
%
logout
exit 0
EOF

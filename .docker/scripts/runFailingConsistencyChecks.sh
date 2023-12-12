#!/usr/bin/env bash

topaz -i -q <<EOF
set gemstone gs64stone user SystemUser pass ${GS64_SYSTEM_USER_PASSWORD}
iferror exit 1
login
output push /opt/gemstone/logs/consistency-checks.log
expectvalue false
run
  Rowan platform instanceMigrator runConsistencyChecks
%
logout
exit 0
EOF

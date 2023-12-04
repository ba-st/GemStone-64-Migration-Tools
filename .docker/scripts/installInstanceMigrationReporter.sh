#!/usr/bin/env bash

echo "Installing Instance Migration Reporter"

topaz -i -q <<EOF
set gemstone gs64stone user SystemUser pass ${GS64_SYSTEM_USER_PASSWORD}
iferror exit 1
login
doit
  StdoutInstanceMigrationReporter install
%
commit
logout
exit 0
EOF

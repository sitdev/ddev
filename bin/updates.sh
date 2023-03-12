#!/usr/bin/env bash

updateSettingsFile() {
  local file=$1
  tail -n +2 "$1" | sed -e 's/export //g' >.conf/.env
  rm -f "${file}"
  git add -A .
}

updateConnectionsFile() {
  local file=$1
  local output=.conf/connections.yaml
  echo "---" >"$output"
  while IFS="|" read -r environment encodedConnectionString; do
    echo "${environment}:" >>"$output"
    echo "  connection: ${encodedConnectionString}" >>"$output"
  done <"$file"
  rm -f "$file"
  git add -A .
}

if [ -f .conf/settings ]; then
  updateSettingsFile .conf/settings
fi

if [ -f .conf/.connections ]; then
  updateConnectionsFile .conf/.connections
fi

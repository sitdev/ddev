#!/bin/bash

{
  yarn config set cache-folder /mnt/ddev-global-cache/yarn || yarn config set cacheFolder /mnt/ddev-global-cache/yarn || true
  npm config set cache /mnt/ddev-global-cache/npm || true
} &> /dev/null
#[ -z "$(which replace)" ] && yarn global add replace || true

nodeVersions=$(nvm ls --no-alias --no-colors)
[ -z "$(echo $nodeVersions | grep v10)" ] && nvm install 10 || true
[ -z "$(echo $nodeVersions | grep v12)" ] && nvm install 12 || true

#!/bin/bash

# $NODE_VER
{
  useNodeVer = "${NODE_VER}" || 16
  nodeVersions=$(nvm ls --no-alias --no-colors)
  if [ -z "$(echo $nodeVersions | grep v${useNodeVer})" ] then 
    nvm install ${useNodeVer} || true
  fi
  nvm use $useNodeVer
  yarn config set cache-folder /mnt/ddev-global-cache/yarn || yarn config set cacheFolder /mnt/ddev-global-cache/yarn || true
  npm config set cache /mnt/ddev-global-cache/npm || true
} &> /dev/null
#[ -z "$(which replace)" ] && yarn global add replace || true

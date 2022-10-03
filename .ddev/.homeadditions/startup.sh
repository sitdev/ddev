#!/bin/bash

[ -z "$(yarn cache dir | grep $DDEV_SITENAME)" ] && yarn config set cache-folder /mnt/ddev-global-cache/yarn/

install_globals() {
  nvm install $1
  which replace
  which webpack-cli
  yarn global add replace webpack webpack-cli gulp bower karma karma-cli
}

nodeVersions=$(nvm ls --no-alias --no-colors)
[ -z "$(echo $nodeVersions | grep v10)" ] && install_globals 10
[ -z "$(echo $nodeVersions | grep v12)" ] && install_globals 12

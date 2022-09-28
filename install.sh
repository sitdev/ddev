#!/bin/bash

branch=${1:-main}
git clone -b ${branch} git@github.com:sitdev/ddev.git .ddev-setup
pwd
cat .ddev-setup
sh .ddev-setup/setup.sh
rm -rf .ddev-setup
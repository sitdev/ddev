#!/bin/bash

echo "${1}"
branch=${1:-main}
git clone -b ${branch} git@github.com:sitdev/ddev.git .ddev-setup
pwd
ls -al .ddev-setup
sh .ddev-setup/setup.sh
rm -rf .ddev-setup
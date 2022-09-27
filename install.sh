#!/bin/bash

branch=${1:-main}
git clone -b ${branch} git@github.com:sitdev/ddev.git .ddev-setup
source .ddev-setup/setup.sh
rm -rf .ddev-setup
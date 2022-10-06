#!/bin/bash

branch=${1:-main}
export INSTALL_TMPDIR="ddev-install"
git clone -b ${branch} git@github.com:sitdev/ddev.git ${INSTALL_TMPDIR} --quiet &> /dev/null
bash "${INSTALL_TMPDIR}/setup.sh"
rm -rf ${INSTALL_TMPDIR}
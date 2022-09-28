#!/bin/bash

branch=${1:-main}
export INSTALL_TMPDIR=$(mktemp -d)
git clone -b ${branch} git@github.com:sitdev/ddev.git ${INSTALL_TMPDIR} --quiet
bash "${INSTALL_TMPDIR}/setup.sh"
rm -rf ${INSTALL_TMPDIR}
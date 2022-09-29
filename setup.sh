#!/bin/bash

export scriptRoot=$(cd "${BASH_SOURCE%/*}" && pwd)

source "${scriptRoot}/bin/check-dependencies.sh"
source "${scriptRoot}/bin/create-settings.sh"
if [ -d .git ]; then
  grep ".ddev" .gitignore &> /dev/null || echo '/.ddev' >> .gitignore
fi
source "${scriptRoot}/bin/build-ddev.sh"

cp -r "${scriptRoot}/Makefile" ./
git add -A .
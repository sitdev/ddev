#!/bin/bash

export scriptRoot=$(cd "${BASH_SOURCE%/*}" && pwd)

source "${scriptRoot}/bin/check-dependencies.sh"
source "${scriptRoot}/bin/create-settings.sh"
if [ -d .git ]; then
  grep ".ddev" .gitignore &> /dev/null || echo '/.ddev' >> .gitignore
fi
rm -rf .ddev
git add -A .
cp -r "${scriptRoot}/.ddev" ./

cat <<EOT > .ddev/config.local.yaml
name: ${SITE_NAME}
web_environment:
  - SITE_TITLE=${SITE_TITLE}
  - SITE_THEME=${SITE_THEME}
EOT
cp -r "${scriptRoot}/Makefile" ./
git add -A .
#!/bin/bash

rm -rf .ddev
git add -A .
cp -r "${scriptRoot}/.ddev" ./

cat <<EOT > .ddev/config.local.yaml
name: ${SITE_NAME}
web_environment:
  - SITE_TITLE=${SITE_TITLE}
  - NODE_VER=${NODE_VER}
EOT
if [ ! -z "${ADDITIONAL_HOSTS}" ]; then
  echo "additional_hostnames:" >> .ddev/config.local.yaml
for host in $ADDITIONAL_HOSTS ; do
  echo "  - $host" >> .ddev/config.local.yaml
done
fi
if [[ "${NODE_VER}" != "16" ]]; then
  cat <<EOT >> .ddev/config.local.yaml
hooks:
  post-start:
  - exec: nvm install ${NODE_VER}
EOT
fi

[ -d .conf/.ddev ] && cp -RT .conf/.ddev/ .ddev/
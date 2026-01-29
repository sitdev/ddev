#!/usr/bin/env bash
[ -f .ddev/.plugin-dev-mode ] && pluginDevMode=1 || true
rm -rf .ddev
git rm -r --cached .ddev 2>/dev/null || true
cp -r "${script_root}/.ddev" ./
[ -z "${pluginDevMode}" ] || touch .ddev/.plugin-dev-mode
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

[ -d .conf/.ddev ] && cp -r .conf/.ddev/ .ddev || true

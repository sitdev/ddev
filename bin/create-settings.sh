#!/bin/bash

data_folder=.conf
settings_file="${data_folder}/settings"

guess_node_ver() {
  local node_ver

  if [[ -f package.json && ! -z "$(grep "situation/webpack" package.json)" ]]; then
    node_ver=12
  elif [ "$(find wp-content/themes -maxdepth 2 -name bower.json)" ]; then
    node_ver=10
  elif [ "$(find wp-content/themes -maxdepth 2 -name package.json -exec grep -rl "situation/webpack" {} \;)" ]; then
    node_ver=12
  else
    node_ver=16
  fi
  echo "$node_ver"
}

is_multisite() {
  grep -q 'WP_ALLOW_MULTISITE.*true' wp-config.php
}
if [ ! -f "$settings_file" ]; then
  mkdir -p "$data_folder"
  touch "$settings_file"
fi

source "$settings_file"
if [ -z "${SITE_NAME}" ]; then
  default_site_name=$(git config --get remote.origin.url | sed 's/\.git$//' | xargs basename)
  read -p -r "Project Slug (ie https://{$default_site_name}.test): [$default_site_name] " SITE_NAME
  SITE_NAME=${SITE_NAME:-$default_site_name}
fi

if [ -z "${SITE_TITLE}" ]; then
  default_site_title=$(echo "$SITE_NAME" | tr - ' ' | awk '{for(j=1;j<=NF;j++){ $j=toupper(substr($j,1,1)) substr($j,2) }}1')
  read -p "Project Title: [$default_site_title] " SITE_TITLE
  SITE_TITLE=${SITE_TITLE:-$default_site_title}
fi

if [ -z "${NODE_VER}" ]; then
  node_guess=$(guess_node_ver)
  read -p "Node Version: [${node_guess}] " NODE_VER
  NODE_VER=${NODE_VER:-${node_guess}}
fi

if is_multisite && [ -z "${ADDITIONAL_HOSTS}" ]; then
  echo "Additional Multisite hosts"
  read -p "(separate by space, no protocol or TLD - eg \"situationuk townhall situationgroup\": " ADDITIONAL_HOSTS
fi

cat <<EOT >$settings_file
#!/bin/bash
export SITE_NAME="${SITE_NAME}"
export SITE_TITLE="${SITE_TITLE}"
export NODE_VER="${NODE_VER}"
EOT

if [ ! -z "${ADDITIONAL_HOSTS}" ]; then
  cat <<EOT >>$settings_file
export ADDITIONAL_HOSTS="${ADDITIONAL_HOSTS}"
EOT
fi

source $settings_file

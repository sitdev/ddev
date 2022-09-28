#!/bin/bash

data_folder=.ddev-data
settings_file="${data_folder}/settings"
if [ ! -f $settings_file ]; then
  mkdir -p $data_folder
  touch $settings_file
fi
source $settings_file
if [ -z "${SITE_NAME}" ]; then
  default_site_name=$(basename $(git config --get remote.origin.url) .git)
  read -p "Project Slug: [$default_site_name] " SITE_NAME
  SITE_NAME=${SITE_NAME:-$default_site_name}
fi

if [ -z "${SITE_TITLE}" ]; then
  default_site_title=$(echo "$SITE_NAME" | tr - ' ' | awk '{for(j=1;j<=NF;j++){ $j=toupper(substr($j,1,1)) substr($j,2) }}1')
  read -p "Project Title: [$default_site_title] " SITE_TITLE
  SITE_TITLE=${SITE_TITLE:-$default_site_title}
fi

if [ -z "${SITE_THEME}" ]; then
  read -p "Theme Folder: [$SITE_NAME] " SITE_THEME
  SITE_THEME=${SITE_THEME:-$SITE_NAME}
fi

cat <<EOT > $settings_file
export SITE_NAME="${SITE_NAME}"
export SITE_TITLE="${SITE_TITLE}"
export SITE_THEME="${SITE_THEME}"
EOT

source $settings_file

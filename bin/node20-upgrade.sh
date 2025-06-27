#!/bin/bash
set -euo pipefail

#!/bin/bash

current_directory=$(pwd)
themes_directory="${current_directory}/wp-content/themes"

# Find valid child themes
valid_child_themes=()
for dir in "${themes_directory}"/*/; do
    if [[ -f "${dir}/style.css" ]] && grep -q "orchestrator" "${dir}/style.css"; then
        valid_child_themes+=("$dir")
    fi
done


# Preparation steps for the upgrade
prepare_for_upgrade() {
    echo "Preparing project for upgrade..."
    make start
    ddev export-db --file=./db-backup.sql.gz
    make update
}


# Update global configuration files
update_config_files() {
    grep -v 'NODE_VER' .conf/.env > temp_file && \
        echo 'NODE_VER="20"' >> temp_file && \
        mv temp_file .conf/.env || {
        echo "Error updating .conf/.env" >&2
        return 1
    }
    sed -i '' 's/^UPDATE_BRANCH="php7"$/UPDATE_BRANCH="arm"/' Makefile
    sed -i '' 's/^UPDATE_BRANCH="main"$/UPDATE_BRANCH="arm"/' Makefile
    sed -i '' "s/github-runner/php8/g" ./.github/workflows/main.yml
    ddev composer config platform --unset
    echo "Updated configuration files"
}

clean() {
    local dir="$1"
    (cd "${dir}" && rm -f package.json yarn.lock webpack.config.js gulpfile.js bower.json .jscsrc .jshintrc .bowerrc assets/manifest.json assets/styles/bower.json)
}

update_theme() {
    local theme_dir="$1"
    local theme_dir_rel="${theme_dir#"$current_directory"/}"
    local project_name
    cp ./template/package.json "${theme_dir}/"
    cp ./template/webpack.config.js "${theme_dir}/"
    echo "20" > "${theme_dir}/.nvmrc"
    
    project_name=$(git config --get remote.origin.url | sed 's/\.git$//' | xargs basename)
    
    sed -i '' "s/orchestrator-child/$project_name/g" "${theme_dir}/package.json"
    
    # Update main.js imports if it exists
    local main_js="${theme_dir}/assets/scripts/main.js"
    rm -f "${theme_dir}/assets/scripts/assets.js"
    if [[ -f "$main_js" ]]; then
        grep -v "../images\|../fonts" "$main_js" > "${main_js}.tmp" && \
            mv "${main_js}.tmp" "$main_js" || {
            echo "Error updating ${main_js}" >&2
            return 1
        }
        ddev mutagen sync
        ddev replace "'@situation/orchestrator'" "'@situation/orchestrator/assets/scripts/theme'" "${theme_dir_rel}assets/scripts/main.js"
        echo "Updated main.js in ${theme_dir}"
    else
        cp ./template/assets/scripts/main.js "${main_js}"
    fi
    local main_scss="${theme_dir}/assets/styles/main.scss"
    if [[ -f "$main_scss" ]] && grep -q "bower" "$main_scss"; then
        cp ./template/assets/styles/main.scss "$main_scss"
        echo "Replaced main.scss in ${theme_dir} due to bower reference"
    fi
    sed -i '' "s/_functions/functions/g" "${main_scss}"
    ddev replace "\.\./images" "./images" "${theme_dir_rel}assets/styles/" -r
    ddev replace "\.\./fonts" "./fonts" "${theme_dir_rel}assets/styles/" -r
}
# Finalize the upgrade
finalize_upgrade() {
    make stop
    make clean
    ddev delete -Oy
    make start
    ddev import-db --file=./db-backup.sql.gz
    rm -f ./db-backup.sql.gz
    ddev yarn cache clean --all
    make update
    ddev mutagen sync
    git add -A .
}

prepare_for_upgrade
ddev mutagen sync

update_config_files

for dir in "${current_directory}" "${valid_child_themes[@]}"; do
    clean "${dir}"
done

git clone git@github.com:situationinteractive/orchestrator-child-theme.git template

for dir in "${valid_child_themes[@]}"; do
    update_theme "${dir}"
done

rm -rf ./template

finalize_upgrade
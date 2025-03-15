#!/bin/bash
set -euo pipefail

# Initialize directories
current_directory=$(pwd)
themes_directory="${current_directory}/wp-content/themes"
child_themes=$(ls -d "${themes_directory}"/*/ | grep -v orchestrator)

# Check if a theme directory has the valid identifier in its style.css
is_valid_theme() {
    local theme_dir="$1"
    if [[ -f "${theme_dir}/style.css" ]] && grep -q "orchestrator" "${theme_dir}/style.css"; then
        return 0
    fi
    return 1
}

# Check if a directory contains an eslint-config in its package.json
check_for_eslint_config() {
    local dir="$1"
    if [[ -f "${dir}/package.json" ]] && grep -q "eslint-config" "${dir}/package.json"; then
        echo "Found upgrade candidate in: ${dir}"
        return 0
    fi
    return 1
}

# Check for upgrade candidate in the global directory or any valid theme directory
check_upgrade_candidate() {
    if check_for_eslint_config "${current_directory}"; then
        return 0
    fi
    for theme_dir in ${child_themes}; do
        if is_valid_theme "${theme_dir}" && check_for_eslint_config "${theme_dir}"; then
            return 0
        fi
    done
    return 1
}

# Update global configuration files
update_config_files() {
    grep -v 'NODE_VER' .conf/.env > temp_file && \
        echo 'NODE_VER="20"' >> temp_file && \
        mv temp_file .conf/.env || {
            echo "Error updating .conf/.env" >&2
            return 1
    }
    sed -i '' 's/^UPDATE_BRANCH="main"$/UPDATE_BRANCH="arm"/' Makefile || {
        echo "Error updating Makefile" >&2
        return 1
    }
    echo "Updated configuration files"
}

cleanup_artifacts() {
    local dir="$1"
    (cd "${dir}" && rm -f package.json yarn.lock webpack.config.js .jscsrc .jshintrc)
}
# Replace the package.json with the template and update the project name
replace_package_json() {
    local template_path="./wp-content/vendor/situation/scripts/node20/build-tools/template/*"
    
    local project_name
    project_name=$(git config --get remote.origin.url | sed 's/\.git$//' | xargs basename)
    
    cp -r $template_path ./ || return 1
    sed -i '' "s/{{project-name}}/$project_name/g" ./package.json
    echo "Updated package.json with project name: $project_name"
}

# Process each valid theme directory in a single pass
process_theme_dirs() {
    for theme_dir in ${child_themes}; do
        if is_valid_theme "${theme_dir}"; then
            echo "Processing theme: ${theme_dir}"
            cleanup_artifacts "${theme_dir}"
            cp ./package.json "${theme_dir}/"
            cp ./webpack.config.js "${theme_dir}/"
            # Update main.js imports if it exists
            local main_js="${theme_dir}/assets/scripts/main.js"
            if [[ -f "$main_js" ]]; then
                grep -v "../images\|../fonts" "$main_js" > "${main_js}.tmp" && \
                    mv "${main_js}.tmp" "$main_js" || {
                        echo "Error updating ${main_js}" >&2
                        return 1
                    }
                echo "Updated main.js in ${theme_dir}"
            fi
            
            # Create assets.js file
            local assets_js="${theme_dir}/assets/scripts/assets.js"
            mkdir -p "$(dirname "$assets_js")"
            cat <<-EOF > "$assets_js"
				import { importAll } from '@situation/setdesign.util';
				
				importAll(require.context('../images', true));
				importAll(require.context('../fonts', true));
EOF
            echo "Created assets.js in ${theme_dir}"
        fi
    done
}

# Preparation steps for the upgrade (global operations)
prepare_for_upgrade() {
    echo "Preparing project for upgrade..."
    make start
    ddev export-db --file=./db-backup.sql.gz
    ddev composer update -o
}

finalize_upgrade() {
    make stop
    make clean
    ddev delete -Oy
    make start
    ddev import-db --file=./db-backup.sql.gz
    rm -f ./db-backup.sql.gz
    make
    ddev mutagen sync
    git add -A .
}

main() {
    if ! check_upgrade_candidate; then
        echo "Error: No upgrade candidate found in project" >&2
        return 1
    fi
    
    prepare_for_upgrade  # Warm up ddev and perform preliminary tasks
    ddev mutagen sync
    update_config_files
    replace_package_json
    process_theme_dirs
    cleanup_artifacts "${current_directory}"
    ddev mutagen sync
    finalize_upgrade
    echo "Node.js 20 upgrade complete"
    return 0
}

main

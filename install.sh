#!/bin/bash
git_branch=${1:-main}
temp_dir=$(mktemp -d)
git clone -b "${git_branch}" git@github.com:sitdev/ddev.git "${temp_dir}" -q && /bin/bash "${temp_dir}/setup.sh"
[ -d "${temp_dir}" ] && rm -rf "${temp_dir}"

#!/usr/bin/env bash
git_branch=${1:-main}
temp_dir=$(mktemp -d)
git clone -b "${git_branch}" https://github.com/sitdev/ddev.git "${temp_dir}" -q && . "${temp_dir}/setup.sh"
[ -d "${temp_dir}" ] && rm -rf "${temp_dir}"

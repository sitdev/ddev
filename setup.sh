#!/bin/bash

export script_root=$(cd "${BASH_SOURCE%/*}" && pwd)
revision=$(cd "$script_root" && git rev-parse HEAD)

if [ -f .ddev/.revision ]; then
  old_revision=$(cat .ddev/.revision)
fi

source "${script_root}/bin/updates.sh"
source "${script_root}/bin/check-dependencies.sh"
source "${script_root}/bin/create-settings.sh"

if [ -d .git ]; then
  grep ".ddev" .gitignore &>/dev/null || echo '/.ddev' >>.gitignore
  grep ".conf/migrations" .gitignore &>/dev/null || echo '/.conf/migrations/*' >>.gitignore

  if [ ! -f .git/hooks/post-checkout ]; then
    mkdir -p .git/hooks
    echo "#!/bin/bash" >.git/hooks/post-checkout
    chmod +x .git/hooks/post-checkout
  fi

  grep -q "mutagen" .git/hooks/post-checkout || echo '[ -z "${DDEV_SITENAME}" ] && (ddev mutagen sync 2> /dev/null || ddev mutagen reset || true)' >>.git/hooks/post-checkout
fi

source "${script_root}/bin/build-ddev.sh"

echo "$revision" >.ddev/.revision

if [[ "$revision" != "$old_revision" ]]; then
  cp "${script_root}/default-readme.md" ./README.md

  if [[ ! -z "$(which ddev)" ]] && ddev exec pwd &> /dev/null; then
    ddev replace "{{SITE_TITLE}}" "$SITE_TITLE" ./README.md --silent
  fi

  echo "Update found..."
fi

cp "${script_root}/Makefile" ./
git add -A .

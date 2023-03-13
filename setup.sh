#!/usr/bin/env bash

export script_root=$(cd "${BASH_SOURCE%/*}" && pwd)
revision=$(cd "$script_root" && git rev-parse HEAD)

if [ -f .ddev/.revision ]; then
  old_revision=$(cat .ddev/.revision)
fi

source "${script_root}/bin/functions.sh"
source "${script_root}/bin/updates.sh"
source "${script_root}/bin/check-dependencies.sh"
source "${script_root}/bin/create-settings.sh"

if [ -d .git ]; then
  grep -q ".ddev" .gitignore || echo '/.ddev' >>.gitignore
  grep -q ".conf/migrations" .gitignore || echo '/.conf/migrations/*' >>.gitignore

  if [ ! -f .git/hooks/post-checkout ]; then
    mkdir -p .git/hooks
    echo "#!/usr/bin/env bash" >.git/hooks/post-checkout
    chmod +x .git/hooks/post-checkout
  fi

  grep -q "mutagen" .git/hooks/post-checkout || echo '[ -z "${DDEV_SITENAME}" ] && (ddev mutagen sync 2> /dev/null || ddev mutagen reset || true)' >>.git/hooks/post-checkout
fi

source "${script_root}/bin/build-ddev.sh"

echo "$revision" >.ddev/.revision

if [[ "$revision" != "$old_revision" ]]; then
  cp "${script_root}/default-readme.md" ./README.md

  if command -v ddev >/dev/null 2>&1 && ddev exec pwd >/dev/null 2>&1; then
    ddev replace "{{SITE_TITLE}}" "$SITE_TITLE" ./README.md --silent
  fi

  echo "Update found..."
fi

cp "${script_root}/Makefile" ./
git add -A .

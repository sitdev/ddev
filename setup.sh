#!/bin/bash

export scriptRoot=$(cd "${BASH_SOURCE%/*}" && pwd)

source "${scriptRoot}/bin/check-dependencies.sh"
source "${scriptRoot}/bin/create-settings.sh"
if [ -d .git ]; then
  grep ".ddev" .gitignore &> /dev/null || echo '/.ddev' >> .gitignore
  if [ ! -f .git/hooks/post-checkout ]; then
      mkdir -p .git/hooks
      echo "#!/bin/bash" > .git/hooks/post-checkout
      chmod +x .git/hooks/post-checkout
  fi
  grep "mutagen" .git/hooks/post-checkout &> /dev/null || echo '[ -z "${DDEV_SITENAME}" ] && (ddev mutagen sync 2> /dev/null || ddev mutagen reset || true)' >> .git/hooks/post-checkout
fi
source "${scriptRoot}/bin/build-ddev.sh"

cp -r "${scriptRoot}/Makefile" ./
git add -A .
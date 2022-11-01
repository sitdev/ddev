#!/bin/bash

export scriptRoot=$(cd "${BASH_SOURCE%/*}" && pwd)
revision=$(cd $scriptRoot && git rev-parse HEAD)
[ -f .ddev/.revision ] && oldVer=$(cat .ddev/.revision) || true

source "${scriptRoot}/bin/check-dependencies.sh"
source "${scriptRoot}/bin/create-settings.sh"
if [ -d .git ]; then
  grep ".ddev" .gitignore &> /dev/null || echo '/.ddev' >> .gitignore
  grep ".conf/migrations" .gitignore &> /dev/null || echo '/.conf/migrations/*' >> .gitignore
  if [ ! -f .git/hooks/post-checkout ]; then
      mkdir -p .git/hooks
      echo "#!/bin/bash" > .git/hooks/post-checkout
      chmod +x .git/hooks/post-checkout
  fi
  grep "mutagen" .git/hooks/post-checkout &> /dev/null || echo '[ -z "${DDEV_SITENAME}" ] && (ddev mutagen sync 2> /dev/null || ddev mutagen reset || true)' >> .git/hooks/post-checkout
fi
source "${scriptRoot}/bin/build-ddev.sh"
echo $revision > .ddev/.revision
if [[ $revision != $oldVer ]]; then
  cp "${scriptRoot}/default-readme.md" ./README.md
  ddev exec pwd 2>/dev/null && ddev replace "{{SITE_TITLE}}" "${SITE_TITLE}" ./README.md --silent || true
  echo "Update found..."
fi
cp "${scriptRoot}/Makefile" ./

git add -A .
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

# The project root is the webroot on our sites, so .conf/ answers to HTTP.
# Deny it at the server level: it holds migration connection secrets and may
# hold locally provided credentials. Rewritten every run — .htaccess is
# gitignored, so it never travels with the repo.
mkdir -p .conf
cat <<'EOT' >.conf/.htaccess
# Deny all web access to project configuration.
<IfModule mod_authz_core.c>
  Require all denied
</IfModule>
<IfModule !mod_authz_core.c>
  Order allow,deny
  Deny from all
</IfModule>
EOT

if [ -d .git ]; then
  # Ensure .gitignore ends with a newline before appending
  [ -f .gitignore ] && [ -n "$(tail -c1 .gitignore)" ] && echo '' >>.gitignore
  grep -q ".ddev" .gitignore || echo '/.ddev' >>.gitignore
  grep -q "llms.txt" .gitignore || echo '/llms.txt' >>.gitignore
  grep -q "conf/org.env" .gitignore || echo '/.conf/org.env' >>.gitignore
  grep -q "conf/auth.json" .gitignore || echo '/.conf/auth.json' >>.gitignore

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

  if command -v ddev >/dev/null 2>&1 && ddev describe 2>/dev/null | grep -qE 'web .*OK'; then
    ddev replace "{{SITE_TITLE}}" "$SITE_TITLE" ./README.md --silent
  fi

  echo "Update found..."
fi

cp "${script_root}/Makefile" ./
git add .gitignore Makefile README.md 2>/dev/null || true

#!/bin/bash

set -xe

source /usr/local/share/bootstrap/common_functions.sh
source /usr/local/share/php/common_functions.sh

load_env

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi

cd /app || exit 1;

set +e
is_nfs
IS_NFS=$?
set -e

run_composer

if [ ! -f bin/n98-magerun.phar ]; then
  as_code_owner "curl -o bin/n98-magerun.phar https://files.magerun.net/n98-magerun.phar"
fi

mkdir -p public/media public/sitemaps public/staging public/var
if [ "$IS_NFS" -ne 0 ]; then
  chown -R "${APP_USER}:${CODE_GROUP}" public/media public/sitemaps public/staging public/var
  chmod -R ug+rw,o-w public/media public/sitemaps public/staging public/var
  chmod -R a+r public/media public/sitemaps public/staging
else
  chmod -R a+rw public/media public/sitemaps public/staging public/var
fi

if [ -d "$FRONTEND_INSTALL_DIRECTORY" ]; then
  mkdir -p pub/static/frontend/

  if [ -d "pub/static/frontend/" ] && [ "$IS_NFS" -ne 0 ]; then
    chown -R "${CODE_OWNER}:${CODE_GROUP}" pub/static/frontend/
  fi

  if [ ! -d "$FRONTEND_INSTALL_DIRECTORY/node_modules" ]; then
    as_code_owner "npm install" "$FRONTEND_INSTALL_DIRECTORY"
  fi
  if [ -z "$GULP_BUILD_THEME_NAME" ]; then
    as_code_owner "gulp $FRONTEND_BUILD_ACTION" "$FRONTEND_BUILD_DIRECTORY"
  else
    as_code_owner "gulp $FRONTEND_BUILD_ACTION --theme='$GULP_BUILD_THEME_NAME'" "$FRONTEND_BUILD_DIRECTORY"
  fi

  if [ -d "pub/static/frontend/" ] && [ "$IS_NFS" -ne 0 ]; then
    chown -R "${APP_USER}:${APP_GROUP}" pub/static/frontend/
  fi
fi

if [ -f "$DIR/install_magento_custom.sh" ]; then
  # shellcheck source=./install_magento_custom.sh
  source "$DIR/install_magento_custom.sh"
fi

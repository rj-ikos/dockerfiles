#!/bin/bash
set -xe

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi

source /usr/local/share/bootstrap/common_functions.sh
source /usr/local/share/php/common_functions.sh

cd /app || exit 1;

if [ -f "tools/docker/config/settings.docker.php" ]; then
  cp tools/docker/config/settings.docker.php /app/docroot/sites/default/settings.docker.php
fi

run_composer

if [ -f "$DIR/install_custom.sh" ]; then
  bash "$DIR/install_custom.sh"
fi

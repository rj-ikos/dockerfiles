#!/bin/bash

do_symfony_build_permissions() {
  if [ "$SYMFONY_MAJOR_VERSION" -eq 2 ]; then
    mkdir -p /app/app/{cache,logs}
  fi
  mkdir -p /app/var

  if [ "$IS_NFS" -ne 0 ]; then
    # Prepare a default parameters.yml. incenteev/parameters-handler can still update it
    mkdir -p /app/app/config
    [ ! -f /app/app/config/parameters.yml ] && echo 'parameters: {}' > /app/app/config/parameters.yml
    setfacl -R -m "d:u:$CODE_OWNER:rwX" -m "u:$CODE_OWNER:rwX" /app/

    # Fix permissions so the web server user can write to cache and logs folders
    if [ "$SYMFONY_MAJOR_VERSION" -eq 2 ]; then
      setfacl -R -m "d:u:$APP_USER:rwX" -m "u:$APP_USER:rwX" /app/app/{cache,logs}
      chmod -R ug+rw,o-rw /app/app/{cache,logs}
    fi
    setfacl -R -m "d:u:$APP_USER:rwX" -m "u:$APP_USER:rwX" /app/var
    chmod -R ug+rw,o-rwx /app/var
  else
    if [ "$SYMFONY_MAJOR_VERSION" -eq 2 ]; then
      chmod -R a+rw /app/app/{cache,logs}
    fi
    chmod -R a+rw /app/var
  fi
}

do_symfony_build() {
  do_symfony_build_permissions
}

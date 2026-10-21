#!/usr/bin/bash
# Usage: create-sealed-secrets-s3-users.sh <user...>
# Regenerates the credentials for the given S3 users (see `s3.identities` in values.yaml).
# Users must be listed explicitly, since regenerating rotates their credentials.
# Restart the filer after rotating credentials, since SeaweedFS only reads them on startup.
set -euo pipefail
script_dir=$(dirname $(realpath $0))

if [ $# -eq 0 ]; then
  echo "Usage: $0 <user...>" >&2
  exit 1
fi

for user in "$@"; do
  case "$user" in
    admin|readonly)
      $script_dir/create-sealed-secret-s3-user.sh "$user"
      ;;
    nextcloud-cnpg)
      $script_dir/create-sealed-secret-s3-user.sh "$user" \
        nextcloud ../../services/nextcloud/templates
      ;;
    authelia-cnpg)
      $script_dir/create-sealed-secret-s3-user.sh "$user" \
        auth ../authelia/templates
      ;;
    lldap-cnpg)
      $script_dir/create-sealed-secret-s3-user.sh "$user" \
        auth ../lldap/resources
      ;;
    *)
      echo "Unknown user: $user" >&2
      exit 1
      ;;
  esac
done

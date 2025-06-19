#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))

$script_dir/create-sealed-secret-oidc-helper.sh headlamp headlamp \
  OIDC_CLIENT_ID OIDC_CLIENT_SECRET \
  ../headlamp/templates

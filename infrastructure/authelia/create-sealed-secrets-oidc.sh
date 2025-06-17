#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))

$script_dir/create-sealed-secret-oidc-helper.sh headlamp headlamp \
  HEADLAMP_CONFIG_OIDC_CLIENT_ID HEADLAMP_CONFIG_OIDC_CLIENT_SECRET \
  ../headlamp/templates

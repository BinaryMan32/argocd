#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))

echo "Go to https://pihole.int.fivebytestudios.com/admin/settings/api"
echo "Switch to Expert mode"
echo "Uncheck 'Permit destructive actions via API' and save"
echo "Configure app password and Enable new app password"
read -e -p 'enter App Password > ' app_password

kubectl create secret generic \
    --dry-run=client \
    --namespace=homepage \
    homepage-pihole \
    --from-literal=HOMEPAGE_VAR_PIHOLE_KEY="$app_password" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/templates/sealed-secret-homepage-pihole.yaml

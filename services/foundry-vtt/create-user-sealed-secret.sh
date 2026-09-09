#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))
echo "Enter credentials for https://foundryvtt.com"
read -e -p 'enter username > ' foundry_username
read -e -p 'enter password > ' foundry_password
kubectl create secret generic \
    --dry-run=client \
    --namespace=foundry-vtt \
    foundry-vtt-user \
    --from-literal=username=$foundry_username \
    --from-literal=password=$foundry_password \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/resources/sealed-secret-user.yaml

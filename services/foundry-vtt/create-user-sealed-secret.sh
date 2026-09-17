#!/usr/bin/bash
if [[ ! -f $PWD/kustomization.yaml ]]; then
  echo "must be run from a foundry-vtt directory with a kustomization.yaml"
  exit 1
fi

INSTANCE="$(basename $PWD)"

echo "Enter credentials for https://foundryvtt.com"
read -e -p 'enter username > ' foundry_username
read -e -p 'enter password > ' foundry_password

kubectl create secret generic \
    --dry-run=client \
    --namespace=foundry-vtt \
    foundry-vtt-user-$INSTANCE \
    --from-literal=username=$foundry_username \
    --from-literal=password=$foundry_password \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$PWD/secrets/resources/sealed-secret-user-$INSTANCE.yaml

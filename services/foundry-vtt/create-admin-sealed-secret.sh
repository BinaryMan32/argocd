#!/usr/bin/bash
if [[ ! -f $PWD/kustomization.yaml ]]; then
  echo "must be run from a foundry-vtt directory with a kustomization.yaml"
  exit 1
fi

INSTANCE="$(basename $PWD)"

# https://github.com/lldap/lldap/blob/main/generate_secrets.sh
print_random () {
  LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32
}

kubectl create secret generic \
    --dry-run=client \
    --namespace=foundry-vtt \
    foundry-vtt-admin-$INSTANCE \
    --from-literal=key="$(print_random)" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$PWD/secrets/resources/sealed-secret-admin-$INSTANCE.yaml

#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))

# https://github.com/lldap/lldap/blob/main/generate_secrets.sh
print_random () {
  LC_ALL=C tr -dc 'A-Za-z0-9!#%&()*+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c 32
}

kubectl create secret generic \
    --dry-run=client \
    --namespace=auth \
    lldap-crypto \
    --from-literal=key_seed="$(print_random)" \
    --from-literal=jwt_secret="$(print_random)" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/resources/sealed-secret-crypto.yaml

kubectl create secret generic \
    --dry-run=client \
    --namespace=auth \
    lldap-admin \
    --from-literal=user_dn=admin \
    --from-literal=user_pass="$(print_random)" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/resources/sealed-secret-admin.yaml

kubectl create secret generic \
    --dry-run=client \
    --namespace=auth \
    lldap-authelia \
    --from-literal=user_dn=authelia \
    --from-literal=user_pass="$(print_random)" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/resources/sealed-secret-authelia.yaml

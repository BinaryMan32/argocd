#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))

# https://github.com/lldap/lldap/blob/main/generate_secrets.sh
print_random () {
  LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 128
}

kubectl create secret generic \
    --dry-run=client \
    --namespace=auth \
    authelia \
    --from-literal=identity_providers.oidc.hmac.key="$(print_random)" \
    --from-literal=identity_validation.reset_password.jwt.hmac.key="$(print_random)" \
    --from-literal=session.encryption.key="$(print_random)" \
    --from-literal=storage.encryption.key="$(print_random)" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/templates/sealed-secret-authelia.yaml

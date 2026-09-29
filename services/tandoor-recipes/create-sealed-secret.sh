#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))

kubectl create secret generic \
    --dry-run=client \
    --namespace=tandoor-recipes \
    tandoor-recipes \
    --from-literal=secret_key="$(base64 /dev/urandom | head -c50)" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/resources/sealed-secret.yaml

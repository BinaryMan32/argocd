#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))

kubectl create secret generic \
    --dry-run=client \
    --namespace=homebox \
    homebox \
    --from-literal=api-key-pepper="$(openssl rand -base64 48)" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/resources/sealed-secret.yaml

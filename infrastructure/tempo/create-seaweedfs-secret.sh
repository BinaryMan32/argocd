#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))
read -e -p 'enter Access Key > ' ACCESS_KEY
read -e -p 'enter Secret Key > ' SECRET_KEY
kubectl create secret generic \
    --dry-run=client \
    --namespace=tempo \
    seaweedfs-tempo \
    --from-literal=ACCESS_KEY=$ACCESS_KEY \
    --from-literal=SECRET_KEY=$SECRET_KEY \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/templates/seaweedfs-tempo-secret.yaml

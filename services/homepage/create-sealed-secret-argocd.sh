#!/usr/bin/bash
set -euo pipefail
script_dir=$(dirname $(realpath $0))

echo "argocd login grpc.argocd.int.fivebytestudios.com --username admin"
token=$(argocd account generate-token --account homepage)

kubectl create secret generic \
    --dry-run=client \
    --namespace=homepage \
    homepage-argocd \
    --from-literal=HOMEPAGE_VAR_ARGOCD_KEY="$token" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/templates/sealed-secret-homepage-argocd.yaml

argocd logout grpc.argocd.int.fivebytestudios.com

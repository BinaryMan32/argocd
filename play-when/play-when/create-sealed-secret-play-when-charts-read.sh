#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))

read -e -p 'enter Deploy token > ' deploy_token

kubectl create secret generic \
    --dry-run=client \
    --namespace=argocd \
    play-when-charts-read \
    --from-literal=type=helm \
    --from-literal=url=https://gitlab.com/api/v4/projects/46393971/packages/helm/stable \
    --from-literal=project=play-when-stage \
    --from-literal=username=argocd-read-helm \
    --from-literal=password=$deploy_token \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/templates/sealed-secret-play-when-charts-read.yaml

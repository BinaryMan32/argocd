#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))

read -e -p 'enter Deploy token > ' deploy_token

create_sealed_secret_helm() {
    environment="$1"
    kubectl create secret generic \
        --dry-run=client \
        --namespace=argocd \
        $environment-charts-read \
        --from-literal=type=helm \
        --from-literal=url=https://gitlab.com/api/v4/projects/46393971/packages/helm/stable \
        --from-literal=project=$environment \
        --from-literal=username=argocd-read-helm \
        --from-literal=password=$deploy_token \
        --output=yaml |
    yq '.metadata.labels."argocd.argoproj.io/secret-type" = "repo-creds"' --yaml-output |
    kubeseal --format=yaml --sealed-secret-file=$script_dir/templates/$environment-sealed-secret-charts-read.yaml
}

create_sealed_secret_helm play-when-stage
create_sealed_secret_helm play-when-prod

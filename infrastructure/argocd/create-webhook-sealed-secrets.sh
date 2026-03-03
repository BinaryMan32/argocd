#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))

# https://github.com/lldap/lldap/blob/main/generate_secrets.sh
print_random () {
  LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 64
}

create_webhook_sealed_secret() {
    name="$1"
    key="$2"
    kubectl create secret generic \
        --dry-run=client \
        --namespace=argocd \
        $name \
        --from-literal=$key="$(print_random)" \
        --output=yaml |
    yq '.metadata.labels."app.kubernetes.io/part-of" = "argocd"' --yaml-output |
    kubeseal --format=yaml --sealed-secret-file=$script_dir/$name-secret.yaml
}

create_webhook_sealed_secret gitlab-webhook secret
create_webhook_sealed_secret github-webhook secret

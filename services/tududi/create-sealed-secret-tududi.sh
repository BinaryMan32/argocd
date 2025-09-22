#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))

read -e -p 'initial user email > ' user_email
read -e -p 'initial user password > ' user_password

kubectl create secret generic \
    --dry-run=client \
    --namespace=auth \
    tududi \
    --from-literal=userEmail="$user_email" \
    --from-literal=userPassword="$user_password" \
    --from-literal=sessionSecret="$(openssl rand -hex 64)" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/resources/sealed-secret.yaml

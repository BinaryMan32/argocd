#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))
echo "Follow instructions at https://www.navidrome.org/docs/usage/external-integrations/#spotify"
read -e -p 'enter id > ' spotify_id
read -e -p 'enter secret > ' spotify_secret
kubectl create secret generic \
    --dry-run=client \
    --namespace=media \
    spotify-navidrome \
    --from-literal=id=$spotify_id \
    --from-literal=secret=$spotify_secret \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/resources/sealed-secret-spotify-navidrome.yaml

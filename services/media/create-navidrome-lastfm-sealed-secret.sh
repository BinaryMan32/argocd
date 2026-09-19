#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))
echo "Follow instructions at https://www.navidrome.org/docs/usage/integration/external-services/#lastfm"
read -e -p 'enter apikey > ' lastfm_apikey
read -e -p 'enter secret > ' lastfm_secret
kubectl create secret generic \
    --dry-run=client \
    --namespace=media \
    navidrome-lastfm \
    --from-literal=apikey=$lastfm_apikey \
    --from-literal=secret=$lastfm_secret \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/resources/sealed-secret-navidrome-lastfm.yaml

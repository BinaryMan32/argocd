#!/bin/bash -xe
script_dir=$(dirname $(realpath $0))

tmp_dir=$(mktemp -d)

# From https://www.authelia.com/reference/guides/generating-secure-values/#generating-an-rsa-keypair
docker run --rm -u "$(id -u):$(id -g)" -v "${tmp_dir}":/keys authelia/authelia:latest authelia crypto pair rsa generate --directory /keys

kubectl create secret generic \
    --dry-run=client \
    --namespace=auth \
    authelia-jwk-rsa \
    --from-file=rsa.2048.key="${tmp_dir}/private.pem" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/templates/sealed-secret-authelia-jwk-rsa.yaml

rm ${tmp_dir}/*.pem
rmdir "${tmp_dir}"

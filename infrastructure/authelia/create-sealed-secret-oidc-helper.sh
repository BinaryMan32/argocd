#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))
client_name="$1"
client_namespace="$2"
output_path="$3"

client_id="$(docker run --rm authelia/authelia:latest authelia crypto rand --length 72 --charset rfc3986)"
client_secret="$(docker run --rm authelia/authelia:latest authelia crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986)"
output_file_name="sealed-secret-oauth-${client_name}.yaml"

create_sealed_secret_oidc () {
    namespace="$1"
    output_file_path="$2"
    mkdir -p "$(dirname "$output_file_path")"
    kubectl create secret generic \
        --dry-run=client \
        --namespace="${namespace}" \
        "authelia-oauth-${client_name}" \
        --from-literal=client-id="$client_id" \
        --from-literal=client-secret="$client_secret" \
        --output=yaml |
    kubeseal --format=yaml --sealed-secret-file="${output_file_path}"
}

create_sealed_secret_oidc "auth" "$script_dir/templates/$output_file_name"
create_sealed_secret_oidc "$client_namespace" "$script_dir/$output_path/$output_file_name"

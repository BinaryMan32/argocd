#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))
client_name="$1"
client_namespace="$2"
output_path="$3"

client_id_raw="$(docker run --rm authelia/authelia:latest authelia crypto rand --length 72 --charset rfc3986)"
client_id="$(echo "$client_id_raw" | grep --perl-regexp --only-matching '(?<=Random Value: ).+')"

client_secret_raw="$(docker run --rm authelia/authelia:latest authelia crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986)"
client_secret_plain="$(echo "$client_secret_raw" | grep --perl-regexp --only-matching '(?<=Random Password: ).+')"
client_secret_digest="$(echo "$client_secret_raw" | grep --perl-regexp --only-matching '(?<=Digest: ).+')"

secret_name="authelia-oidc-${client_name}"
output_file_name="sealed-secret-${secret_name}.yaml"

create_sealed_secret_oidc () {
    namespace="$1"
    client_secret="$2"
    output_file_path="$3"
    mkdir -p "$(dirname "$output_file_path")"
    kubectl create secret generic \
        --dry-run=client \
        --namespace="${namespace}" \
        "${secret_name}" \
        --from-literal=client-id="$client_id" \
        --from-literal="$client_secret" \
        --output=yaml |
    kubeseal --format=yaml --sealed-secret-file="${output_file_path}"
}

create_sealed_secret_oidc "auth" "client-secret-digest=$client_secret_digest" "$script_dir/templates/$output_file_name"
create_sealed_secret_oidc "$client_namespace" "client-secret=$client_secret_plain" "$script_dir/$output_path/$output_file_name"

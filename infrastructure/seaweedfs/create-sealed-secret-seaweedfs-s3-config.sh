#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))

# https://github.com/lldap/lldap/blob/main/generate_secrets.sh
print_random () {
  LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c $1
}

function generate_config() {
  cat <<JSON
{
  "identities": [
    {
      "name": "Admin",
      "actions": [
        "Admin"
      ],
      "credentials": [
        {
          "accessKey": "$(print_random 32)",
          "secretKey": "$(print_random 64)"
        }
      ]
    },
    {
      "name": "ReadOnly",
      "actions": [
        "Read",
        "List"
      ],
      "credentials": [
        {
          "accessKey": "$(print_random 32)",
          "secretKey": "$(print_random 64)"
        }
      ]
    }
  ]
}
JSON
}

kubectl create secret generic \
    --dry-run=client \
    --namespace=seaweed \
    seaweedfs-s3-config \
    --from-literal=seaweedfs_s3_config="$(generate_config)" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/templates/sealed-secret-seaweedfs-s3-config.yaml

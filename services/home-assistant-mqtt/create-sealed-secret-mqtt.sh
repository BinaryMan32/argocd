#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))

# https://github.com/lldap/lldap/blob/main/generate_secrets.sh
print_random () {
  LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32
}

kubectl create secret generic \
    --dry-run=client \
    --namespace=home-assistant \
    mqtt \
    --from-literal=flashforge-username="flashforge" \
    --from-literal=flashforge-password="$(print_random)" \
    --from-literal=home-assistant-username="home-assistant" \
    --from-literal=home-assistant-password="$(print_random)" \
    --from-literal=tasmota-username="tasmota" \
    --from-literal=tasmota-password="$(print_random)" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/resources/sealed-secret-mqtt.yaml

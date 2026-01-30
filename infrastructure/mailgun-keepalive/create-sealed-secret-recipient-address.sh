#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))

read -e -p 'enter recipient email address > ' recipient_email_address

kubectl create secret generic \
    --dry-run=client \
    --namespace=mail \
    mailgun-keepalive-recipient-address \
    --from-literal=recipient_email_address="$recipient_email_address" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/resources/mailgun-keepalive-recipient-address.yaml

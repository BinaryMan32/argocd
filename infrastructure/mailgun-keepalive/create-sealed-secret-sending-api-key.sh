#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))

echo "Go to https://app.mailgun.com/mg/sending/mail.fivebytestudios.com/settings?tab=keys"
MAILGUN_SENDING_KEY_NAME="keepalive-$(date +%Y-%m-%d)"
echo "'Add sending key' with name ${MAILGUN_SENDING_KEY_NAME}"
echo "Click 'Create sending key' and copy the API key"
read -e -p 'enter Sending API key > ' sending_api_key

kubectl create secret generic \
    --dry-run=client \
    --namespace=mail \
    mailgun-keepalive-sending-api-key \
    --from-literal=sending_api_key="$sending_api_key" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/resources/mailgun-keepalive-sending-api-key.yaml

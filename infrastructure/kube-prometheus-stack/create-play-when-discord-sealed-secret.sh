#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))
echo "Follow instructions at https://promlabs.com/blog/2022/12/23/sending-prometheus-alerts-to-discord-with-alertmanager-v0-25-0/#setting-up-a-webhook-on-discord"
read -e -p 'enter webhook url > ' webhook_url
kubectl create secret generic \
    --dry-run=client \
    --namespace=kube-prometheus-stack \
    play-when-discord-webhook \
    --from-literal=webhook_url=$webhook_url \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/templates/play-when-discord-webhook.yaml

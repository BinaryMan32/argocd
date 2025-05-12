#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))
echo "Go to https://account.protonvpn.com/account-password#openvpn"
read -e -p 'enter OpenVPN / IKEv2 username > ' protonvpn_username
read -e -p 'enter OpenVPN / IKEv2 password > ' protonvpn_password
kubectl create secret generic \
    --dry-run=client \
    --namespace=arr \
    protonvpn-credentials \
    --from-literal=username=$protonvpn_username \
    --from-literal=password=$protonvpn_password \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/resources/sealed-secret-protonvpn-credentials.yaml

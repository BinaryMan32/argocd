#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))
echo "Go to https://account.proton.me/u/0/vpn/WireGuard"
echo "1. Enter a name associated with this kubernetes cluster"
echo "2. Change platform to 'GNU/Linux'"
echo "3. Select VPN options NAT-PMP and VPN Accelerator"
echo "4. Click 'Create' button"
read -e -p 'enter PrivateKey > ' wireguard_private_key
kubectl create secret generic \
    --dry-run=client \
    --namespace=media \
    protonvpn-credentials \
    --from-literal=wireguard_private_key=$wireguard_private_key \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/resources/sealed-secret-protonvpn-credentials.yaml

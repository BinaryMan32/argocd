#!/usr/bin/bash
script_dir=$(dirname $(realpath $0))

echo "Go to https://app.mailgun.com/mg/sending/mail.fivebytestudios.com/settings?tab=smtp"
echo "Reset Password"
read -e -p 'enter Password > ' smtp_password

kubectl create secret generic \
    --dry-run=client \
    --namespace=auth \
    authelia-smtp \
    --from-literal=password="$smtp_password" \
    --output=yaml |
kubeseal --format=yaml --sealed-secret-file=$script_dir/templates/sealed-secret-authelia-smtp.yaml

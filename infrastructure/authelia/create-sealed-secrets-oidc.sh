#!/usr/bin/bash
# Usage: create-sealed-secrets-oidc.sh [client...]
# Regenerates the secrets for the given clients, or all clients if none given.
script_dir=$(dirname $(realpath $0))

clients=("$@")
if [ ${#clients[@]} -eq 0 ]; then
  clients=(headlamp argocd grafana)
fi

for client in "${clients[@]}"; do
  case "$client" in
    headlamp)
      $script_dir/create-sealed-secret-oidc-helper.sh headlamp headlamp \
        headlamp OIDC_CLIENT_ID OIDC_CLIENT_SECRET \
        ../headlamp/templates
      ;;
    argocd)
      $script_dir/create-sealed-secret-oidc-helper.sh argocd argocd \
        argocd client-id client-secret \
        ../argocd \
        app.kubernetes.io/part-of=argocd
      ;;
    grafana)
      # Keys are environment variable names, loaded with envFromSecret
      $script_dir/create-sealed-secret-oidc-helper.sh grafana grafana \
        kube-prometheus-stack GF_AUTH_GENERIC_OAUTH_CLIENT_ID GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET \
        ../kube-prometheus-stack/templates
      ;;
    *)
      echo "Unknown client: $client" >&2
      exit 1
      ;;
  esac
done

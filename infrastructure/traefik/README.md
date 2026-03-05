# Traefik

Based on [Deploy Multiple Gateways Example](https://github.com/traefik/traefik-helm-chart/blob/master/EXAMPLES.md#deploy-multiple-gateways-with-a-single-traefik-deploymentdaemonset).

## Helm Template

Running `helm template` returns an error:

```text
Error: execution error at (traefik/charts/traefik/templates/servicemonitor.yaml:5:10): ERROR: You have to deploy monitoring.coreos.com/v1 first
```

Use `--api-versions` to work around this validation:

```sh
helm template traefik infrastructure/traefik --values infrastructure/traefik/values.yaml --api-versions monitoring.coreos.com/v1
```

To see only `Gateway` definitions:

```sh
helm template traefik infrastructure/traefik --values infrastructure/traefik/values.yaml --api-versions monitoring.coreos.com/v1 | yq 'select(.kind=="Gateway")' --yaml-output
```

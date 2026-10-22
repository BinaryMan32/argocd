# kube-prometheus-stack

References:

- [Alertmanager Configuration](https://prometheus.io/docs/alerting/latest/configuration/)

## Secrets

Alertmanager requires secrets in order to send alert notifications.

### FBS Discord Secret

Receives all alerts.

```sh
./infrastructure/kube-prometheus-stack/create-discord-webhook-fbs-sealed-secret.sh
```

### Play When Discord Secret

Receives only alerts in `play-when*` namespaces.

```sh
./infrastructure/kube-prometheus-stack/create-discord-webhook-play-when-sealed-secret.sh
```

## Testing

Access to alertmanager is protected by authelia.
Use a `port-forward` to bypass.

```sh
kubectl port-forward -n kube-prometheus-stack svc/kube-prometheus-stack-alertmanager 9093:9093
```

Send test alert.

```sh
curl -iH 'Content-Type: application/json' http://localhost:9093/api/v2/alerts -d '[{
  "labels": {
    "alertname": "testing",
    "namespace": "play-when-dev",
    "severity": "critical",
    "status": "open"
  },
  "annotations": {
    "summary": "Test alert",
    "description": "This is a mock alert for testing"
  }
}]'
```

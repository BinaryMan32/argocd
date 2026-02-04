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

### Slack Secret

Set up a [slack webhook](https://api.slack.com/messaging/webhooks#getting-started)

Create secret and seal with `kubeseal`:

```sh
echo -n 'WEBHOOK_URL' \
  | kubectl create secret generic slack-api --namespace=kube-prometheus-stack \
    --dry-run=client --from-file=url=/dev/stdin -o yaml \
  | kubeseal --format yaml \
    >infrastructure/kube-prometheus-stack/templates/slack-api-secret.yaml
```

## Testing

Access to the  ingress is protected by authelia.
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

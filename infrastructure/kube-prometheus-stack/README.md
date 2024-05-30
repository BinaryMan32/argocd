# kube-prometheus-stack

References:
- [Alertmanager Configuration](https://prometheus.io/docs/alerting/latest/configuration/)

## Slack Secret

Set up a [slack webhook](https://api.slack.com/messaging/webhooks#getting-started)

Create secret and seal with `kubeseal`:
```
echo -n 'WEBHOOK_URL' \
  | kubectl create secret generic slack-api --namespace=kube-prometheus-stack \
    --dry-run=client --from-file=url=/dev/stdin -o yaml \
  | kubeseal --format yaml \
    >infrastructure/kube-prometheus-stack/templates/slack-api-secret.yaml
```

Send test alert:
```sh
curl -iH 'Content-Type: application/json' https://alertmanager.int.fivebytestudios.com/api/v2/alerts -d '[{
  "labels": {
    "alertname": "testing",
    "namespace": "default",
    "severity": "critical",
    "status": "open"
  },
  "annotations": {
    "summary": "Test alert",
    "description": "This is a mock alert for testing"
  }
}]'
```

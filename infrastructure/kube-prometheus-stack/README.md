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

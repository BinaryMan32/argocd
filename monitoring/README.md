# Monitoring

Prometheus Operator & Grafana provided by [kube-prometheus-stack][].

Before installing, create a secret to log into grafana:
```
kubectl create secret generic \
  --namespace=monitoring \
  grafana-login \
  --from-literal=admin-user=admin \
  --from-literal=admin-password='<password>'
```

To retrieve the credentials:
```
kubectl -n monitoring get secret grafana-login \
  --template='{{index .data "admin-user" | base64decode}}
{{index .data "admin-password" | base64decode}}
'
```

[kube-prometheus-stack]: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

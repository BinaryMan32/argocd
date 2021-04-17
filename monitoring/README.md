# Monitoring

Before installing, create a secret to log into grafana:
```
kubectl create secret generic \
  --namespace=monitoring \
  grafana-login \
  --from-literal=username=admin \
  --from-literal=password='<password>'
```

To retrieve the credentials:
```
kubectl -n monitoring get secret grafana-login \
  --template='{{index .data "admin-user" | base64decode}}
{{index .data "admin-password" | base64decode}}
'
```

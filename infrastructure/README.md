# Infrastructure

## Bootstrapping

ArgoCD can be managed by ArgoCD, but must be installed using other means first.
Since ArgoCD requires coredns to function, it must also be installed manually.

See the `README.md` files for each app:
1. [coredns](./coredns/)
2. [argocd](./argocd/)

## Install Intranet CA Root Certificate

See [cert-manager](./cert-manager) for details on the intranet CA.

### Operating System (Ubuntu)

Copy self-signed root certificate from kubernetes secret to local directory:
```
kubectl -n cert-manager get secret intranet-ca --template='{{index .data "tls.crt"}}' \
  | base64 -d \
  | sudo tee /usr/local/share/ca-certificates/five_byte_studios_intranet_ca.crt
```
Create symlinks into `/etc/ssl/certs/`
```
sudo update-ca-certificates
```

### Chrome

Chrome uses a separate certificate database, which can be updated with:
```
sudo apt install libnss3-tools
certutil -d sql:$HOME/.pki/nssdb -A -t C -n "five_byte_studios_intranet_ca" \
  -i /usr/local/share/ca-certificates/five_byte_studios_intranet_ca.crt
```

Reference: https://stackoverflow.com/questions/19692787/how-to-install-certificate-in-browser-settings-using-command-prompt

## Manual Kubernetes Changes

Some changes require modifications to resources created by k3s. Since these
aren't managed by any apps, these steps must be performed manually instead of
updating deployment configuration.

### Monitoring

Prometheus Operator & Grafana provided by [kube-prometheus-stack][].

Before installing, create a secret to log into grafana:
```
kubectl create secret generic \
  --namespace=kube-prometheus-stack \
  grafana-login \
  --from-literal=admin-user=admin \
  --from-literal=admin-password='<password>'
```

To retrieve the credentials:
```
kubectl -n kube-prometheus-stack get secret grafana-login \
  --template='{{index .data "admin-user" | base64decode}}
{{index .data "admin-password" | base64decode}}
'
```

After deploying, prometheus wouldn't start due to a permission denied error.
For some reason, the `fsGroup` setting didn't actually change ownership of
the longhorn volume. To fix this, detach the volume in the longhorn UI and
attach to one of the cluster nodes. SSH, mount the volume, and run:
```
sudo chown 1000:2000 .
```

### Storage Classes

After deploying all infrastructure apps, the storage classes should be:
```
$ kubectl get storageclass
NAME                   PROVISIONER                                     RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path                           Delete          WaitForFirstConsumer   false                  18h
longhorn               driver.longhorn.io                              Retain          Immediate              true                   26m
nfs                    cluster.local/nfs-subdir-external-provisioner   Delete          Immediate              true                   101m
```

[kube-prometheus-stack]: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

## Sealed Secrets

Install `kubeseal` client binary:
```
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.20.2/kubeseal-0.20.2-linux-amd64.tar.gz
tar -xvzf kubeseal-0.20.2-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
rm kubeseal-0.20.2-linux-amd64.tar.gz
```

See [kube-prometheus-stack](./kube-prometheus-stack/README.md) for example of creating a sealed secret.

See [sealed-secrets][] for additional details.

[sealed-secrets]: https://github.com/bitnami-labs/sealed-secrets

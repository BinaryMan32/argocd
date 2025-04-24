# Infrastructure

## Bootstrapping

ArgoCD can be managed by ArgoCD, but must be installed using other means first.
Since ArgoCD requires coredns to function, it must also be installed manually.

See the `README.md` files for each app:

1. [coredns](./coredns/)
2. [argocd](./argocd/)

At this point you can use argocd via port forwarding.

Deploy infrastructure parent app project by running in `infrastructure/`:

```sh
kubectl apply -f project-app.yaml
```

All of the apps will appear in the ArgoCD UI.
Sync ArgoCD so that it can take ownership of deployed resources, but it may
show as `Progressing` since nothing exists to handle the ingress yet.

Deploy the following which enable access to intranet services through ingress.

1. [ingress-nginx-intranet](./infrastructure/templates/ingress-nginx-intranet.yaml)
2. [metallb](./metallb/) (can now use ArgoCD load balancer instead of port forward)
3. [longhorn](./infrastructure/templates/longhorn.yaml) (needs ingress)
   Manually sync some resources beforehand: ServiceAccount, ClusterRole, ClusterRoleBinding
4. [k8s-gateway](./infrastructure/templates/k8s-gateway.yaml) (needs ingress)
5. [pihole](./infrastructure/templates/pihole.yaml) (needs longhorn)
6. [sealed-secrets](./infrastructure/templates/sealed-secrets.yaml)
7. [kube-prometheus-stack](./kube-prometheus-stack/) (needs longhorn, sealed-secrets)
8. [cert-manager](./cert-manager/) (needs prometheus)

Tools for accessing and maintaining cluster nodes.

- [kured](./infrastructure/templates/kured.yaml)

Additional infrastructure used only by non-infrastructure projects.

1. [nfs-subdir-external-provisioner](./infrastructure/templates/nfs-subdir-external-provisioner.yaml)
2. [minio-operator](./infrastructure/templates/minio-operator.yaml)
3. [minio-tenant](./infrastructure/templates/minio-tenant.yaml)
4. [cloudnative-pg](./infrastructure/templates/cloudnative-pg.yaml)
5. [ingress-nginx](./infrastructure/templates/ingress-nginx.yaml) (don't deploy until router port-forward)

## Install Intranet CA Root Certificate

See [cert-manager](./cert-manager) for details on the intranet CA.

### Operating System (Ubuntu)

Copy self-signed root certificate from kubernetes secret to local directory:

```sh
kubectl -n cert-manager get secret intranet-ca --template='{{index .data "tls.crt"}}' \
  | base64 -d \
  | sudo tee /usr/local/share/ca-certificates/five_byte_studios_intranet_ca.crt
```

Create symlinks into `/etc/ssl/certs/`

```sh
sudo update-ca-certificates
```

### Chrome

Chrome uses a separate certificate database, which can be updated with:

```sh
sudo apt install libnss3-tools
certutil -d sql:$HOME/.pki/nssdb -A -t C -n "five_byte_studios_intranet_ca" \
  -i /usr/local/share/ca-certificates/five_byte_studios_intranet_ca.crt
```

Reference: <https://stackoverflow.com/questions/19692787/how-to-install-certificate-in-browser-settings-using-command-prompt>

## Manual Kubernetes Changes

Some changes require modifications to resources created by k3s. Since these
aren't managed by any apps, these steps must be performed manually instead of
updating deployment configuration.

### Pihole

Before installing, create admin password secret:

```sh
kubectl create secret generic \
  --namespace=pihole \
  pihole-admin \
  --from-literal=password='PASSWORD'
```

After installing, go to <http://192.168.8.103/admin> and pick `Settings`

- under `DNS`, change to `Potentially dangerous options` - `Permit all origins`.

### Monitoring

Prometheus Operator & Grafana provided by [kube-prometheus-stack][].

Before installing, create a secret to log into grafana:

```sh
kubectl create secret generic \
  --namespace=kube-prometheus-stack \
  grafana-login \
  --from-literal=admin-user=admin \
  --from-literal=admin-password='<password>'
```

To retrieve the credentials:

```sh
kubectl -n kube-prometheus-stack get secret grafana-login \
  --template='{{index .data "admin-user" | base64decode}}
{{index .data "admin-password" | base64decode}}
'
```

After deploying, prometheus wouldn't start due to a permission denied error.
For some reason, the `fsGroup` setting didn't actually change ownership of
the longhorn volume. To fix this, detach the volume in the longhorn UI and
attach to one of the cluster nodes. SSH, mount the volume, and run:

```sh
sudo chown 1000:2000 .
```

### TopoLVM

TopoLVM uses webhooks. To work webhooks properly, add a label to the target namespace. We also recommend to use a dedicated namespace.

```sh
kubectl label namespace kube-system topolvm.io/webhook=ignore
```

The same change will be applied to the `topolvm-system` automatically when it's created by ArgoCD.

### Storage Classes

After deploying all infrastructure apps, the storage classes should be:

```sh
kubectl get storageclass
```

```text
NAME                   PROVISIONER                                     RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path                           Delete          WaitForFirstConsumer   false                  18h
longhorn               driver.longhorn.io                              Retain          Immediate              true                   26m
nfs                    cluster.local/nfs-subdir-external-provisioner   Delete          Immediate              true                   101m
```

[kube-prometheus-stack]: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

Deploy coredns to handle internal DNS and external queries.

## CoreDNS

```sh
helm dependency update
helm install --namespace=kube-system coredns .
```

### Troubleshooting

See <https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/>

Run DNS test query:

```sh
kubectl run -i -t dns-test --image=alpine --restart=Never --rm -- nslookup kubernetes.default.svc.cluster.local
```

Example output:

```text
Server:         10.43.0.10
Address:        10.43.0.10:53


Name:   kubernetes.default.svc.cluster.local
Address: 10.43.0.1

pod "dns-test" deleted
```

Test forwarding queries to k8s-gateway

```sh
kubectl run -i -t intranet-dns-test --image=alpine --restart=Never --rm -- nslookup argocd.int.fivebytestudios.com
```

Test external queries

```sh
kubectl run -i -t external-dns-test --image=alpine --restart=Never --rm -- nslookup google.com
```

### References

See the following resources:

- <https://www.reddit.com/r/homelab/comments/ipsc4r/howto_k8s_metallb_and_external_dns_access_for/>
- <https://github.com/coredns/deployment>
- <https://github.com/coredns/helm/tree/master/stable/coredns>

## Sealed Secrets

Install `kubeseal` client binary:

```sh
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.29.0/kubeseal-0.29.0-linux-amd64.tar.gz
tar -xvzf kubeseal-0.29.0-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
rm kubeseal kubeseal-0.29.0-linux-amd64.tar.gz
```

See [kube-prometheus-stack](./kube-prometheus-stack/README.md) for example of creating a sealed secret.

See [sealed-secrets][] for additional details, in particular how to
[backup][sealed-secrets-backup] and restore sealing secrets.

[sealed-secrets]: https://github.com/bitnami-labs/sealed-secrets
[sealed-secrets-backup]:https://github.com/bitnami-labs/sealed-secrets?tab=readme-ov-file#how-can-i-do-a-backup-of-my-sealedsecrets

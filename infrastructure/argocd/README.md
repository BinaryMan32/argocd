# ArgoCD

See [Getting Started](https://argoproj.github.io/argo-cd/getting_started/)

For inital bootstrapping, run the following in this directory:

```sh
kubectl create namespace argocd
kustomize build | kubectl apply -f -
```

The `kustomization.yaml` includes the following changes:

* set namespace to `argocd`
* [argocd-cm.yaml](./argocd-cm.yaml): list users
* [argocd-cmd-params-cm](./argocd-cmd-params-cm.yaml): enabled apps in other namespaces
* [argocd-rbac-cm](./argocd-rbac-cm.yaml): assign users to groups
* [ingress.yaml](./ingress.yaml): access outside cluster
* [load-balancer](./load-balancer.yaml): enabled load balancer as described in
  [Getting Started](https://argoproj.github.io/argo-cd/getting_started/#3-access-the-argo-cd-api-server)

Note: it should be possible to have `kubectl` run kustomize directly with
`kubectl apply -k`, but it seemed this command was unable to retrieve resources
from a URL.

The deployment will take a few minutes. You can monitor its progress using:

```sh
watch kubectl get all -n argocd
```

Once it's ready (all pods running), forward a local port to the service:

```sh
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

And then visit <http://localhost:8080/>

From [Argo CD Getting Started][argocd-getting-started], the initial `admin` password can be read using:

```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Change password using argocd client:

```sh
argocd login localhost:8080
```

```text
WARNING: server certificate had error: x509: certificate signed by unknown authority. Proceed insecurely (y/n)? y
Username: admin
Password:
'admin:login' logged in successfully
Context 'localhost:8080' updated
$ argocd account update-password
*** Enter current password:
*** Enter new password:
*** Confirm new password:
Password updated
```

Delete the now unused secret:

```sh
kubectl -n argocd delete secret argocd-initial-admin-secret
```

[argocd-getting-started]: https://argo-cd.readthedocs.io/en/stable/getting_started/

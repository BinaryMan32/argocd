The argocd getting started guide:
https://argoproj.github.io/argo-cd/getting_started/

Uses a docker repository which doesn't support arm64:
https://registry.hub.docker.com/r/argoproj/argocd

But there are arm64 community provided images:
https://registry.hub.docker.com/r/cyrilix/argocd

For inital bootstrapping, run the following in this directory:
```
kubectl create namespace argocd
kustomize build | kubectl apply -f -
```

The `kustomization.yaml` includes the following changes:
* set namespace to `argocd`
* Use arm64 images instead of amd64
* [load-balancer](./load-balancer.yaml): enabled load balancer as described in
  [Getting Started](https://argoproj.github.io/argo-cd/getting_started/#3-access-the-argo-cd-api-server)
* [argocd-cm.yaml](./argocd-cm.yaml): specify secrets used to
  [read from private repositories][argocd-private].

Note: it should be possible to have `kubectl` run kustomize directly with
`kubectl apply -k`, but it seemed this command was unable to retrieve resources
from a URL.

The deployment will take a few minutes. You can monitor its progress using:
```
watch kubectl get all -n argocd
```

Once it's ready (all pods running), forward a local port to the service:
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
And then visit http://localhost:8080/

From [Argo CD Getting Started][argocd-getting-started], the initial `admin`
password can be read using:
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Change password using argocd client:
```
$ argocd login localhost:8080
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
```
kubectl -n argocd delete secret argocd-initial-admin-secret
```

[argocd-private]: https://argoproj.github.io/argo-cd/user-guide/private-repositories/
[argocd-getting-started]: https://argo-cd.readthedocs.io/en/stable/getting_started/

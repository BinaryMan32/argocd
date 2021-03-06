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
* configured to enabled load balancer as described in
  [Getting Started](https://argoproj.github.io/argo-cd/getting_started/#3-access-the-argo-cd-api-server)
* [argocd.yaml](./argocd.yaml): specify secrets used to
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

Change the password right away since it's set to the name of the initial
`argocd-server` pod which may change later.

[argocd-private]: https://argoproj.github.io/argo-cd/user-guide/private-repositories/

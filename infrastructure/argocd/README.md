# ArgoCD

See [Getting Started](https://argoproj.github.io/argo-cd/getting_started/)

The `kustomization.yaml` includes the following changes:

* set namespace to `argocd`
* [argocd-cm.yaml](./argocd-cm.yaml): list users
* [argocd-cmd-params-cm](./argocd-cmd-params-cm.yaml): enabled apps in other namespaces
* [argocd-rbac-cm](./argocd-rbac-cm.yaml): assign users to groups
* [grpcroute.yaml](./grpcroute.yaml): CLI access outside cluster
* [httproute.yaml](./httproute.yaml): web access outside cluster

## Initial Manual Deploy

For initial bootstrapping, run the following in this directory:

```sh
kubectl create namespace argocd
kustomize build | kubectl apply -f -
```

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

## Webhooks

### GitLab

For each of the following projects:

* [play-when-argocd](https://gitlab.com/play-when/play-when-argocd/-/hooks)
* [play-when-auth-chart](https://gitlab.com/play-when/play-when-auth-chart/-/hooks)
* [play-when-backend-chart](https://gitlab.com/play-when/play-when-backend-chart/-/hooks)
* [play-when-discord-bot-chart](https://gitlab.com/play-when/play-when-discord-bot-chart/-/hooks)
* [play-when-frontend-chart](https://gitlab.com/play-when/play-when-frontend-chart/-/hooks)

Add a webhook with the following settings:

* Name: `ArgoCD Webhook`
* URL: `https://gitlab-webhook.argocd.wildfreddy.fivebytestudios.com/api/webhook`
* Secret token: from secret `gitlab-webhook` in `argocd` namespace
  `kubectl -n argocd get secret gitlab-webhook -o jsonpath="{.data.secret}" | base64 -d`
* Trigger:
  * Push events
    * All branches

### GitHub

For each of the following repositories:

* [argocd](https://github.com/BinaryMan32/argocd/settings/hooks)

Add a webhook with the following settings:

* Payload URL: `https://github-webhook.argocd.wildfreddy.fivebytestudios.com/api/webhook`
* Content type: `application/json`
* Secret: from secret `github-webhook` in `argocd` namespace
  `kubectl -n argocd get secret github-webhook -o jsonpath="{.data.secret}" | base64 -d`
* Which events would you like to trigger this webhook?
  * Just the push event

[argocd-getting-started]: https://argo-cd.readthedocs.io/en/stable/getting_started/

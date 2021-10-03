Deploys [Disc Golf Fanatic][dgf-gitlab] from gitlab.

Create a [deploy token][] for the [disc-golf-fanatic gitlab group][dgf-group]
with has the scope `read_repository`.

Add this token to a secret used by argocd to read the repository:
```
kubectl create secret generic \
  --namespace=argocd \
  gitlab-disc-golf-fanatic \
  --from-literal=username=argocd-read \
  --from-literal=password=<token>
```

The [argocd configmap][] was updated to reference this secret.
See argocd documentation on how to [read from private repositories][argocd-private].

Create a [deploy token][] with has the scope `read_registry`.

Add this token for use as an image pull secret:
```
for namespace in disc-golf-fanatic-{dev,prod}; do
kubectl create namespace $namespace
kubectl create secret docker-registry \
    --namespace=$namespace \
    dgf-docker-registry \
    --docker-server=registry.gitlab.com \
    --docker-username=kubernetes-pull \
    --docker-password=<token>
done
```

To start managing in argocd, run:
```
kubectl apply -f project-app.yaml
```

Once deployed, static web content should be accessible via:
* https://fivebytestudios.com/
* https://www.fivebytestudios.com/

The disc golf fanatic app should be accessible via:
* https://www.fivebytestudios.com/dgf

[dgf-gitlab]: https://gitlab.com/disc-golf-fanatic
[deploy token]: https://docs.gitlab.com/ee/user/project/deploy_tokens/index.html#creating-a-deploy-token
[dgf-group]: https://gitlab.com/groups/disc-golf-fanatic/-/settings/repository#js-deploy-tokens
[argocd configmap]: ../infrastructure/argocd/argocd-cm.yaml
[argocd-private]: https://argoproj.github.io/argo-cd/user-guide/private-repositories/

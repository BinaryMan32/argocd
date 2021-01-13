Deploys [five byte studios applications][fbs-gitlab] from gitlab.

Create a [deploy token][] for the [disc-golf-fanatic gitlab group][dgf-group]
with has the scope `read_repository`.

Add this token to a secret used by argocd to read the repository:
```
kubectl create secret generic \
  --namespace=argocd \
  gitlab-five-byte-studios \
  --from-literal=username=<username> \
  --from-literal=password=<token>
```

The [argocd configmap](../argocd/argocd-cm.yaml) was updated to reference this secret.
See argocd documentation on how to [read from private repositories][argocd-private].

To start managing in argocd, run:
```
kubectl apply -f fbs-web.yaml
kubectl apply -f disc-golf-fanatic.yaml
```

Once deployed, static web content should be accessible via:
* https://fivebytestudios.com/
* https://www.fivebytestudios.com/

The disc golf fanatic app should be accessible via:
* https://www.fivebytestudios.com/dgf

[fbs-gitlab]: https://gitlab.com/disc-golf-fanatic
[deploy token]: https://docs.gitlab.com/ee/user/project/deploy_tokens/index.html#creating-a-deploy-token
[dgf-group]: https://gitlab.com/groups/disc-golf-fanatic/-/settings/repository/deploy_token
[argocd-private]: https://argoproj.github.io/argo-cd/user-guide/private-repositories/

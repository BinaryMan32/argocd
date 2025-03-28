# Play When Gitlab Chart

Deploys the [Play When][play-when-group] application, which includes:

- [Gitlab Chart][play-when-gitlab-chart] - Gitlab runners to support Play When pipelines

## Setup

Create a [deploy token][] from [Play When Settings][play-when-settings-deploy]:

- Name: `play-when-gitlab-read-repository`
- Expiration date: leave blank
- Username: `argocd-read`
- Scopes: `read_repository`

Create a secret used by argocd to read the repository, replacing `TOKEN`:

```sh
kubectl create secret generic \
  --namespace=argocd \
  play-when-gitlab-read-repository \
  --from-literal=type=git \
  --from-literal=url=https://gitlab.com/play-when/ \
  --from-literal=project=play-when \
  --from-literal=username=argocd-read \
  --from-literal=password=TOKEN
```

Apply a label to the secret so that ArgoCD will use it when fetching repositories:

```sh
kubectl label secret \
  --namespace=argocd \
  play-when-gitlab-read-repository \
  argocd.argoproj.io/secret-type=repo-creds
```

See argocd documentation on how to [read from private repositories][argocd-private].

[deploy token]: https://docs.gitlab.com/ee/user/project/deploy_tokens/index.html#creating-a-deploy-token
[play-when-group]: https://gitlab.com/play-when
[play-when-settings-deploy]: https://gitlab.com/groups/play-when/-/settings/repository#js-deploy-tokens
[play-when-gitlab-chart]: https://gitlab.com/play-when/play-when-gitlab-chart
[argocd-private]: https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#repository-credentials

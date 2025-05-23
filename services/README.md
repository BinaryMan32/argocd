# Services

## Play When Gitlab Runner

Follow instructions to create a [group runner](https://docs.gitlab.com/ci/runners/runners_scope/#group-runners).

Create namespace:

```sh
kubectl create namespace play-when-gitlab
```

Create a secret with the runner `TOKEN` using the command:

```sh
kubectl create secret generic \
  --namespace=play-when-gitlab \
  gitlab-runner \
  --from-literal=runner-registration-token='' \
  --from-literal=runner-token='TOKEN'
```

For reference, see the [gitlab runner secret template](https://gitlab.com/gitlab-org/charts/gitlab-runner/-/blob/main/templates/secrets.yaml).
Although `runner-registration-token` is deprecated, it must still be set to an empty string in the secret as of `v0.73.4`.

## Kubernetes Dashboard

1. In a terminal, run
   ```
   $ kubectl proxy
   Starting to serve on 127.0.0.1:8001
   ```
2. Connect to the proxied dashboard
   http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:https/proxy/
3. Create cluster role binding and get token as described in:
   https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md

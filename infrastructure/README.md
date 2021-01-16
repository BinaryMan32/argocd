# Infrastructure

## Bootstrapping

ArgoCD can be managed by ArgoCD, but must be installed using other means first.
Since ArgoCD requires coredns to function, it must also be installed manually.

See the `README.md` files for each app:
1. [coredns](./coredns/)
2. [argocd](./argocd/)

## Manual Steps

Some changes require modifications to resources created by k3s. Since these
aren't managed by any apps, these steps must be performed manually instead of
updating deployment configuration.

### Default Storage Class

After deploying all infrastructure apps, there are two default storage classes:
```
$ kubectl get storageclass
NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  4d10h
longhorn (default)     driver.longhorn.io      Delete          Immediate              true                   29m
```

To fix this, mark `local-path` as non-default as described in
[Kubernetes - Changing the default StorageClass][k8s-default-storageclass]:
```
$ kubectl patch storageclass local-path -p \
  '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
storageclass.storage.k8s.io/local-path patched
```

Now there is only a single default:
```
$ kubectl get storageclass
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path           rancher.io/local-path   Delete          WaitForFirstConsumer   false                  4d10h
longhorn (default)   driver.longhorn.io      Delete          Immediate              true                   30m
```

[k8s-default-storageclass]: https://kubernetes.io/docs/tasks/administer-cluster/change-default-storage-class/#changing-the-default-storageclass

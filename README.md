Manages deployments on a raspberry pi cluster using argocd:
* [argocd](./argocd/)
* [coredns](./coredns/)

Repository structure based on:
* https://chris-sanders.github.io/2020-10-07-argo-in-argo/
* https://github.com/chris-sanders/argocd

Testing a helm project:
```
helm dependency build
helm template project-name . -f values.yaml
```

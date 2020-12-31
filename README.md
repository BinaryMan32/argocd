Manages deployments on a raspberry pi cluster using argocd.
Each service contains its own README.md with documentation and references.

Repository structure based on:
* https://chris-sanders.github.io/2020-10-07-argo-in-argo/
* https://github.com/chris-sanders/argocd

To start managing an app in argocd, run in its directory:
```
kubectl apply -f argocd/app.yaml
```

Testing a helm project:
```
helm dependency build
helm template project-name . -f values.yaml
```

Manages deployments on a raspberry pi cluster using argocd.
Each service contains its own README.md with documentation and references.

## Bootstrapping

Set up the [infrastructure](./infrastructure) project first.

## References

Repository structure based on:
* https://chris-sanders.github.io/2020-10-07-argo-in-argo/
* https://github.com/chris-sanders/argocd
* https://argoproj.github.io/argo-cd/operator-manual/cluster-bootstrapping/

To start managing a project in argocd, run in its directory:
```
kubectl apply -f project-app.yaml
```

Testing a helm project:
```
helm dependency build
helm template project-name . -f values.yaml
```

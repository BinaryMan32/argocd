Deploys home-assistant using [k8s-at-home helm chart][k8s-at-home].

Start managing this app with argocd:
```
kubectl apply -f argocd/app.yaml
```

Once it's deployed, forward a local port to the service:
```
kubectl -n home-assistant port-forward svc/home-assistant 8123:8123
```
And visit http://localhost:8123/

[k8s-at-home]: https://github.com/k8s-at-home/charts/tree/master/charts/home-assistant

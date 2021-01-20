# Services

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

## Heimdall

Set password manually using:
```
kubectl -n heimdall exec -it service/heimdall -- htpasswd -c /config/nginx/.htpasswd $LOGNAME
```

See links with documentation on the helm chart and docker image:
* https://github.com/k8s-at-home/charts/tree/master/charts/heimdall
* https://hub.docker.com/r/linuxserver/heimdall

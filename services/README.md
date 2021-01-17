# Services

## Heimdall

Set password manually using:
```
kubectl -n heimdall exec -it service/heimdall -- htpasswd -c /config/nginx/.htpasswd $LOGNAME
```

See links with documentation on the helm chart and docker image:
* https://github.com/k8s-at-home/charts/tree/master/charts/heimdall
* https://hub.docker.com/r/linuxserver/heimdall

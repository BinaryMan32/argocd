Deploys nextcloud using [nextcloud helm][], with a postgres database supplied
by [kubegres][].

From the `nextcloud-secrets` subdir run:
```
helm install -n nextcloud --create-namespace nextcloud-secrets .
```

Get initial admin password:
```
kubectl -n nextcloud get secret nextcloud-admin \
  --template='{{.data.password | base64decode | printf "%s\n"}}'
```


[nextcloud helm]: https://github.com/nextcloud/helm/tree/master/charts/nextcloud
[kubegres]: https://www.kubegres.io/doc/getting-started.html

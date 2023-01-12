Deploys nextcloud using [nextcloud helm][], with a postgres database supplied
by [kubegres][].

# Setup

From the `nextcloud-secrets` subdir run:
```
helm install -n nextcloud --create-namespace nextcloud-secrets .
```

Get initial admin password:
```
kubectl -n nextcloud get secret nextcloud-admin \
  --template='{{.data.password | base64decode | printf "%s\n"}}'
```

# Initial Setup

If using persistence on NFS, nextcloud will fail to do the initial install or
upgrade with a message similar to:
```
Initializing nextcloud 22.2.3.0 ...
rsync: [generator] chown "/var/www/html/data" failed: Operation not permitted (1)
rsync error: some files/attrs were not transferred (see previous errors) (code 23) at main.c(1333) [sender=3.2.3]
```
The `entrypoint.sh` script exits on error when `rsync` fails. This would be
fine if it retried since `chown` is expected to fail and unnecessary because of
the `all_squash` server side NFS configuration. However, `entrypoint.sh` will
try to copy the `data` directory every time it starts because the destination
directory is empty, which is always the case because the source dir is empty as
well. Creating a dummy file bypasses the issue.
```
touch /nfs/k8s/volumes/nextcloud/nextcloud-nextcloud-data/data/NOT_EMPTY
```

# Database

Forward port:
```
kubectl -n nextcloud port-forward service/nextcloud-postgres 5432
```

Connect:
```
PGPASSWORD=$(kubectl -n nextcloud get secret nextcloud-database \
  --template='{{.data.nextcloudPassword | base64decode}}') \
  psql -h localhost nextcloud nextcloud
```

Restore:
```
gzip -cd dump-nextcloud.sql.gz \
  | kubectl exec -i -n nextcloud nextcloud-postgres-1-0 -- bash -c \
  'PGPASSWORD=$POSTGRES_MY_DB_PASSWORD exec psql -U nextcloud'
```

[nextcloud helm]: https://github.com/nextcloud/helm/tree/master/charts/nextcloud
[kubegres]: https://www.kubegres.io/doc/getting-started.html

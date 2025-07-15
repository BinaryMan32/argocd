Deploys nextcloud using [nextcloud helm][].

# Setup

Get initial admin password:
```
kubectl -n nextcloud get secret nextcloud-admin \
  --template='{{.data.password | base64decode | printf "%s\n"}}'
```

To change password in `nextcloud-admin` `SealedSecret`, run script
`create-sealed-secret-nextcloud-admin.sh`.

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

[nextcloud helm]: https://github.com/nextcloud/helm/tree/master/charts/nextcloud

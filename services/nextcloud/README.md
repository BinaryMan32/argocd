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

# Upgrading

If using persistence on NFS, nextcloud will fail to do the initial install or
upgrade with a message similar to:
```
Initializing nextcloud 22.2.3.0 ...
rsync: [generator] chown "/var/www/html/data" failed: Operation not permitted (1)
```
This occurs because NFS doesn't allow files to be owned by root.

To work around this, build a new docker image using the following `Dockerfile`.
```
FROM nextcloud:22.2.3-apache
RUN sed --in-place=.bak 's/\(rsync_options="-rlD\)[^"]\+/\1/' /entrypoint.sh
```
The must be built on a machine with `arm64` architecture.
```
cat Dockerfile | docker build -t nextcloud:22.2.3-apache-fix-chown -
```

Patch the deployment to load the new image:
```
kubectl -n nextcloud patch deploy/nextcloud --patch '
spec:
  template:
    spec:
      containers:
      - name: nextcloud
        image: nextcloud:22.2.3-apache-fix-chown
'
```
At this point, the pod will fail to start because the image only exists locally.

Create a tarfile of the image:
```
docker save --output nextcloud_22.2.3-apache-fix-chown.tar \
  nextcloud:22.2.3-apache-fix-chown
```

Copy the tarfile to the host which is trying to start the container and import:
```
sudo k3s ctr images import nextcloud_22.2.3-apache-fix-chown.tar
```

[nextcloud helm]: https://github.com/nextcloud/helm/tree/master/charts/nextcloud
[kubegres]: https://www.kubegres.io/doc/getting-started.html

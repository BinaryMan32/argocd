# NFS provisioner

This directory doesn't actually deploy anything, but it documents manual setup
of the NFS server and verification.

See [mercury-nfs-subdir-external-provisioner.yaml][] which uses
[nfs-subdir-external-provisioner][] to provision volumes of class `mercury-nfs`.

## Configuring nfs server

### TrueNAS

Create a separate `generic` dataset for each of the below

- `provisioned`
- `manual`

Edit permissions as follows:

- user: `nobody` (check **Apply User**)
- group: `nogroup` (check **Apply Group**)

Create a NFS share for each with the following settings:

- mapall user: `nobody`
- mapall group: `nogroup`
- security: `SYS`
- networks: `192.168.8.0/24`

### Debian

Install the NFS service:

```sh
sudo apt update
sudo apt install nfs-kernel-server
```

`nfs-subdir-external-provisioner` will run as root, but the nfs server will map
to the user `nobody` to avoid trusting remote `root` users which grants access
to all files. Ensure that the provisioner has permission to create directories:

```sh
sudo mkdir -p /mnt/raid/nfs/k8s/griffin/{volumes,longhorn-backup}
sudo chown nobody:nogroup /mnt/raid/nfs/k8s/griffin/{volumes,longhorn-backup}
```

Create nfs directory and bind mount storage into it

```sh
sudo mkdir -p /srv/nfs/k8s
echo "/mnt/raid/nfs/k8s /srv/nfs/k8s none bind 0 0" | sudo tee -a /etc/fstab
sudo mount /srv/nfs/k8s
```

Configure exported shares in `/etc/exports`:

```text
/srv/nfs     192.168.0.0/16(rw,fsid=0,no_subtree_check,sync)
/srv/nfs/k8s 192.168.8.0/24(rw,nohide,insecure,no_subtree_check,sync,all_squash) 192.168.0.0/24(rw,nohide,no_subtree_check,sync,all_squash)
```

Note use of `all_squash` to ensure new files are owned by `nobody`/`nogroup`.

Reload config:

```sh
sudo service nfs-kernel-server reload
```

## Verification

### Mounting

Verify from a client:

```sh
sudo mkdir /mnt/nfs-test
sudo mount -t nfs4 helios64:/k8s /mnt/nfs-test
sudo umount /mnt/nfs-test
```

Note that you won't have permissions to actually write files.

### From Kubernetes

Deploy:

```sh
kubectl create -f test-claim.yaml -f test-pod.yaml
```

Now check your NFS Server for the file SUCCESS.

```sh
kubectl delete -f test-claim.yaml -f test-pod.yaml
```

Now check the folder has been deleted.

[mercury-nfs-subdir-external-provisioner.yaml]: ../infrastructure/templates/mercury-nfs-subdir-external-provisioner.yaml
[nfs-subdir-external-provisioner]: https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner

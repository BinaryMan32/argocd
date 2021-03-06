Deploys home-assistant using [k8s-at-home helm chart][k8s-at-home].

Once it's deployed, forward a local port to the service:
```
kubectl -n home-assistant port-forward svc/home-assistant 8123:8123
```
And visit http://localhost:8123/

Or use the ingress via https://home-assistant.wildfreddy.fivebytestudios.com/

Only a single node has a SSD rather than a sdcard, but the microk8s storage
addon could allocate a `PersistentVolume` from any node's disk. To avoid this,
explicitly create `PersistentVolume` and `PersistentVolumeClaim` resources for
home-assistant storage. To create directories for this storage:
```
ssh pegasus3 sudo mkdir -p /var/home-assistant/{config,mqtt}
```
See [Reserving a PersistentVolume][reserve-pv].

[k8s-at-home]: https://github.com/k8s-at-home/charts/tree/master/charts/home-assistant
[reserve-pv]: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reserving-a-persistentvolume

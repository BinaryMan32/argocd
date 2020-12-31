Deploys home-assistant using [k8s-at-home helm chart][k8s-at-home].

Once it's deployed, forward a local port to the service:
```
kubectl -n home-assistant port-forward svc/home-assistant 8123:8123
```
And visit http://localhost:8123/

Or, add the following to `/etc/hosts`:
```
192.168.6.100	home-assistant.wildfreddy.fivebytestudios.com
```
And use the ingress via http://home-assistant.wildfreddy.fivebytestudios.com/

[k8s-at-home]: https://github.com/k8s-at-home/charts/tree/master/charts/home-assistant

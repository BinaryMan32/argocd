Deploy coredns to handle internal DNS and external queries.

## Bootstrapping

```
helm dependency update
helm install --namespace=kube-system coredns .
```

## Troubleshooting

See https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/

Create a pod to run DNS test query:
```
kubectl apply -f test/dnsutils.yaml
```

Example of successful test query:
```
$ kubectl exec -it dnsutils -- nslookup kubernetes.default

Server:		10.43.0.10
Address:	10.43.0.10#53

Name:	kubernetes.default.svc.cluster.local
Address: 10.43.0.1
```

Clean up pod:
```
kubectl delete pod dnsutils
```

## References

See the following resources:
* https://www.reddit.com/r/homelab/comments/ipsc4r/howto_k8s_metallb_and_external_dns_access_for/
* https://github.com/coredns/deployment
* https://github.com/coredns/helm/tree/master/stable/coredns

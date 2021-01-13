Deploy coredns to handle internal DNS and external queries.

## Bootstrapping

```
helm install --namespace=kube-system coredns .
```

## References

See the following resources:
* https://www.reddit.com/r/homelab/comments/ipsc4r/howto_k8s_metallb_and_external_dns_access_for/
* https://github.com/coredns/deployment
* https://github.com/coredns/helm/tree/master/stable/coredns

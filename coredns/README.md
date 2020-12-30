Runs coredns to serve DNS records for load balancer IPs.

Router should be configured to use `service.loadBalancerIP` as a DNS server.

Start managing this app with argocd:
```
kubectl apply -f argocd/app.yaml
```

Created based on:
https://www.definit.co.uk/2020/01/running-coredns-for-lab-name-resolution/

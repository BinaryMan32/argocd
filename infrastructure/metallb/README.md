# MetalLB

Deployment based on:
* [MetalLB - Installation With Kustomize][metallb-kustomize]
* `config.yaml` from [MetalLB & DNS HowTo][metallb-howto]
* `secret.yaml` generated using:
  ```
  kubectl create secret generic -n metallb-system memberlist \
    --from-literal=secretkey="$(openssl rand -base64 128)" \
    --dry-run=client -o yaml > secret.yaml
  ```

[metallb-howto]: https://www.reddit.com/r/homelab/comments/ipsc4r/howto_k8s_metallb_and_external_dns_access_for/
[metallb-kustomize]: https://metallb.universe.tf/installation/#installation-with-kustomize
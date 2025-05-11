# Arr

Deploys the `*arr` stack of services.
I couldn't find helm charts for most of these components.
This is based on the blog [Deploying a Kubernetes-Based Media Server][k8s-media].
It was easier to use `kustomize` instead of creating helm charts, since it's only for this deployment so the configuration doesn't need to be generalized.
See the [kustomization file documentation][kustomization]

[k8s-media]: https://merox.dev/blog/kubernetes-media-server/
[kustomization]: https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/

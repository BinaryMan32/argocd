#!/bin/bash -e
for kustomization in $(find . -name kustomization.yaml); do
    echo "${kustomization}"
    kubectl kustomize "$(dirname "${kustomization}")" > /dev/null
done

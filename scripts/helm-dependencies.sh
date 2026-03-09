#!/bin/bash -xe
find . -name Chart.lock |
xargs yq --raw-output --arg rep_conf "$REPOSITORY_CONFIG" '.dependencies | map("helm repo add --repository-config=helm-dependencies.yaml \"" + .name + "\" \"" + .repository + "\"") | .[]' |
sh --

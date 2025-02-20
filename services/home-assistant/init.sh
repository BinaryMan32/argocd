#!/bin/sh
set -e

apk add --no-cache rsync

# Copy the config from the configmap over the config in the persistent volume
# This allows temporary edits for experimentation which are discarded when the pod restarts
rsync -rv /config-templates/ /config

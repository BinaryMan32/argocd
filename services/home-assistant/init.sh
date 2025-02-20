#!/bin/sh
set -e

# Copy the config from the configmap over the config in the persistent volume
# This allows temporary edits for experimentation which are discarded when the pod restarts
# Busybox cp -R (recursive) preserves symlinks by default, use -L to disable
mkdir -p /config && cp -RL /config-templates/* /config

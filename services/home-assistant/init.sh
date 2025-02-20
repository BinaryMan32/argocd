#!/bin/sh
set -e

# Copy the config from the configmap over the config in the persistent volume
# This allows temporary edits for experimentation which are discarded when the pod restarts
mkdir -p /config && cp -r /config-templates/* /config

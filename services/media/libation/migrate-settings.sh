#!/usr/bin/bash
# Copies desktop Libation settings, accounts and database into the running libation pod.
# config/install-libation.sh moves them into place when the pod restarts, before libation starts.
# Usage: migrate-settings.sh [libation files dir], default ~/.local/share/Libation
# Set KUBECTL_ARGS to pass extra arguments to kubectl, e.g. KUBECTL_ARGS="--context griffin"
set -euo pipefail

src=$(realpath "${1:-$HOME/.local/share/Libation}")
dest=/config/Libation
kubectl="kubectl ${KUBECTL_ARGS:-} --namespace=media"

if pgrep -ix libation > /dev/null; then
    echo "Close the desktop Libation first, so the database isn't copied mid-write" >&2
    exit 1
fi

pod=$($kubectl get pod --selector=app.kubernetes.io/name=libation,app.kubernetes.io/component=ui --output=name)
if [ -z "$pod" ]; then
    echo "No libation pod found, scale the libation deployment to 1 first" >&2
    exit 1
fi

staging=$(mktemp -d)
trap 'rm -rf "$staging"' EXIT

# logs aren't needed, everything else is settings, accounts, database or cache
# appsettings.json only points at the desktop's files dir, LIBATION_FILES_DIR replaces it in the pod
rsync -a --exclude='Log*' --exclude=appsettings.json "$src/" "$staging/"

# point paths at the pod's home directory, books are mounted at the same path as the desktop
python3 -I - "$staging" "$dest" <<'EOF'
import json, pathlib, sys
staging, dest = pathlib.Path(sys.argv[1]), sys.argv[2]

def rewrite(name, update):
    path = staging / name
    data = json.loads(path.read_text())
    update(data)
    path.write_text(json.dumps(data, indent=2))

def settings(data):
    for sink in data.get("Serilog", {}).get("WriteTo", []):
        if "path" in sink.get("Args", {}):
            sink["Args"]["path"] = f"{dest}/Log.log"

rewrite("Settings.json", settings)
EOF

echo "Copying $(du -sh "$staging" | cut -f1) to $pod"
tar -C "$staging" -cf - . |
    $kubectl exec -i "$pod" -- sh -c 'rm -rf /config/libation-import && mkdir /config/libation-import && tar -xf - -C /config/libation-import'

echo "Restarting $pod to import settings"
$kubectl delete "$pod"

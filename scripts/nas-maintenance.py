#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = ["kubernetes"]
# ///
"""Scales Deployments and StatefulSets using volumes on the NAS down to 0 before
NAS maintenance, and back up to 1 afterwards.

A volume is on the NAS if its PVC uses one of the NAS StorageClasses, or its PV
is an NFS volume (static or nfs.csi.k8s.io) served by the NAS.

Example:
  scripts/nas-maintenance.py down
  # perform maintenance
  scripts/nas-maintenance.py up
"""
import argparse
import dataclasses
import re
import sys
import time

from kubernetes import client, config

DEFAULT_CONTEXT = 'griffin'
DEFAULT_NFS_SERVER = '192.168.8.9'
DEFAULT_STORAGE_CLASSES = ['nfs-mercury-griffin-delete', 'nfs-mercury-griffin-retain']


@dataclasses.dataclass(frozen=True)
class Workload:
  kind: str
  namespace: str
  name: str
  replicas: int

  def __str__(self):
    return f'{self.kind}/{self.name} -n {self.namespace}'


def claim_names(pod_spec):
  return {
    volume.persistent_volume_claim.claim_name
    for volume in pod_spec.volumes or []
    if volume.persistent_volume_claim
  }


def nfs_server(pv):
  if pv.spec.nfs:
    return pv.spec.nfs.server
  if pv.spec.csi and pv.spec.csi.driver == 'nfs.csi.k8s.io':
    return (pv.spec.csi.volume_attributes or {}).get('server')
  return None


def find_claims(core, storage_classes, server):
  """Returns (namespace, name) of each PVC on the NAS."""
  claims = {
    (pvc.metadata.namespace, pvc.metadata.name)
    for pvc in core.list_persistent_volume_claim_for_all_namespaces().items
    if pvc.spec.storage_class_name in storage_classes
  }
  for pv in core.list_persistent_volume().items:
    if pv.spec.claim_ref and nfs_server(pv) == server:
      claims.add((pv.spec.claim_ref.namespace, pv.spec.claim_ref.name))
  return claims


def uses_claims(namespace, pod_spec, claims):
  return any((namespace, name) in claims for name in claim_names(pod_spec))


def find_workloads(apps, claims):
  workloads = []
  for deployment in apps.list_deployment_for_all_namespaces().items:
    namespace = deployment.metadata.namespace
    if uses_claims(namespace, deployment.spec.template.spec, claims):
      workloads.append(Workload('deployment', namespace, deployment.metadata.name, deployment.spec.replicas))

  for statefulset in apps.list_stateful_set_for_all_namespaces().items:
    namespace = statefulset.metadata.namespace
    name = statefulset.metadata.name
    # PVCs created from volumeClaimTemplates are named <template>-<statefulset>-<ordinal>
    template_patterns = [
      re.compile(rf'{re.escape(template.metadata.name)}-{re.escape(name)}-\d+')
      for template in statefulset.spec.volume_claim_templates or []
    ]
    if uses_claims(namespace, statefulset.spec.template.spec, claims) or any(
      claim_namespace == namespace and pattern.fullmatch(claim_name)
      for claim_namespace, claim_name in claims
      for pattern in template_patterns
    ):
      workloads.append(Workload('statefulset', namespace, name, statefulset.spec.replicas))

  return sorted(workloads, key=lambda w: (w.namespace, w.kind, w.name))


def scale(apps, workload, replicas):
  body = {'spec': {'replicas': replicas}}
  if workload.kind == 'deployment':
    apps.patch_namespaced_deployment_scale(workload.name, workload.namespace, body)
  else:
    apps.patch_namespaced_stateful_set_scale(workload.name, workload.namespace, body)


def pods_using(core, claims):
  return sorted(
    f'{pod.metadata.namespace}/{pod.metadata.name}'
    for pod in core.list_pod_for_all_namespaces().items
    if uses_claims(pod.metadata.namespace, pod.spec, claims)
  )


def format_list(title, items):
  return '\n  '.join([f'{title} ({len(items)}):', *items])


def wait_for_pods(core, claims, timeout):
  """Waits until no pod mounts any of the claims, including pods not owned by a scaled workload."""
  deadline = time.monotonic() + timeout
  last_pods = None
  while pods := pods_using(core, claims):
    if pods != last_pods:
      print(format_list('Waiting for pods to terminate', pods))
      last_pods = pods
    if time.monotonic() > deadline:
      sys.exit(format_list(f'Timed out after {timeout}s, pods still using the NAS', pods))
    time.sleep(2)
  print('No pods are using the NAS, ready for maintenance')


def main():
  parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
  parser.add_argument('action', choices=['down', 'up'])
  parser.add_argument('--context', default=DEFAULT_CONTEXT, help='kubeconfig context (default: %(default)s)')
  parser.add_argument('--nfs-server', default=DEFAULT_NFS_SERVER, help='NAS address in NFS PVs (default: %(default)s)')
  parser.add_argument(
    '--storage-class', dest='storage_classes', action='append', metavar='STORAGE_CLASS',
    help=f'NAS StorageClass, may be repeated (default: {", ".join(DEFAULT_STORAGE_CLASSES)})',
  )
  parser.add_argument('--dry-run', action='store_true', help='show what would be scaled without changing anything')
  parser.add_argument('-v', '--verbose', action='store_true', help='also print the PVCs found on the NAS')
  parser.add_argument('--timeout', type=int, default=300, help='seconds to wait for pods to terminate (default: %(default)s)')
  args = parser.parse_args()
  storage_classes = set(args.storage_classes or DEFAULT_STORAGE_CLASSES)

  config.load_kube_config(context=args.context)
  print(f'Using context {args.context}')

  core = client.CoreV1Api()
  apps = client.AppsV1Api()

  known_classes = {sc.metadata.name for sc in client.StorageV1Api().list_storage_class().items}
  if unknown_classes := storage_classes - known_classes:
    sys.exit(f'Unknown StorageClass(es): {", ".join(sorted(unknown_classes))}')

  claims = find_claims(core, storage_classes, args.nfs_server)
  if args.verbose:
    print(format_list('PVCs on the NAS', sorted(f'{namespace}/{name}' for namespace, name in claims)))
  workloads = find_workloads(apps, claims)

  if args.action == 'down':
    to_scale = [w for w in workloads if w.replicas > 0]
    replicas = 0
  else:
    to_scale = [w for w in workloads if w.replicas == 0]
    replicas = 1

  if not to_scale:
    print(f'Nothing to scale {args.action}')
  for workload in to_scale:
    print(f'{"Would scale" if args.dry_run else "Scaling"} {workload} from {workload.replicas} to {replicas}')
    if not args.dry_run:
      scale(apps, workload, replicas)

  if args.action == 'down':
    if args.dry_run:
      if pods := pods_using(core, claims):
        print(format_list('Pods currently using the NAS', pods))
    else:
      wait_for_pods(core, claims, args.timeout)


if __name__ == '__main__':
  main()

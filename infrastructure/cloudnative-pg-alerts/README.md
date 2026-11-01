# CloudNativePG Alerts

Prometheus rules for all CloudNativePG clusters, in any namespace.

| File | Source |
|---|---|
| [cluster-chart-rules.yaml](./resources/cluster-chart-rules.yaml) | [cluster chart](https://github.com/cloudnative-pg/charts/tree/main/charts/cluster/prometheus_rules), adapted |
| [default-rules.yaml](./resources/default-rules.yaml) | [default alerts](https://github.com/cloudnative-pg/cloudnative-pg/blob/main/docs/src/samples/monitoring/prometheusrule.yaml) from the docs, unchanged |
| [backup-rules.yaml](./resources/backup-rules.yaml) | not from upstream |

## Adapting Upstream Rules

The cluster chart's rules are written for one cluster at a time, so they're adapted to group by `namespace` and `job`.
`job` is `<namespace>/<PodMonitor name>`, and each PodMonitor is named after its cluster.
Keep `namespace` on every alert, since alertmanager routes alerts by namespace.

Keep alert names, annotations and rule order the same as upstream, and change only label matchers and aggregations,
so that upstream changes are easy to diff.
Each file's header lists the upstream rules that were omitted and why.

## Updating

Each file copied from upstream has a `# renovate:` comment with the upstream version.
Renovate opens a PR when a new upstream version is released, but the PR only changes the version in the comment.
Before merging, diff the upstream rules between the two versions and update the file.
The PR description links to the upstream rule history and includes a command that shows the diff.
Most cluster chart releases don't change the rules, so the command often has no output, and the PR can be merged
as is.

To check for upstream changes since the last update without waiting for Renovate, run these commands with `VERSION`
replaced by the tag in the URL below each file's `# renovate:` comment, such as `cluster-v0.9.0` or `v1.30.1`:

```sh
# cluster-chart-rules.yaml
gh api repos/cloudnative-pg/charts/compare/VERSION...main \
  --jq '.files[] | select(.filename | startswith("charts/cluster/prometheus_rules/")) | "--- \(.filename) (\(.status))\n\(.patch)"'

# default-rules.yaml
gh api repos/cloudnative-pg/cloudnative-pg/compare/VERSION...main \
  --jq '.files[] | select(.filename == "docs/src/samples/monitoring/prometheusrule.yaml") | "--- \(.filename) (\(.status))\n\(.patch)"'
```

Runbooks for new alerts are in `charts/cluster/docs/runbooks/`, which these commands don't show.

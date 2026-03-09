#!/bin/bash -e
for chart in $(find . -name Chart.yaml); do
    echo "${chart}"
    chart_dir="$(dirname $chart)"
    if [ ! -d "${chart_dir}/charts" ] || [ ! -f "${chart_dir}/Chart.lock" ]; then
        echo "building helm dependencies"
        helm dependency build "${chart_dir}"
    fi
    helm template "$(basename "${chart_dir}")" "${chart_dir}" --values "${chart_dir}/values.yaml" --api-versions monitoring.coreos.com/v1 > /dev/null
done

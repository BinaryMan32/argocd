# Jaeger

Deploys [Jaeger][jaeger-docs] using the [OpenTelemetry Operator][opentelemetry-operator].

[jaeger-docs]: https://www.jaegertracing.io/docs/
[opentelemetry-operator]: https://opentelemetry.io/docs/platforms/kubernetes/operator/

## Documentation

The deployment documentation for Jaeger v2 is pretty misleading:

- [Deploying on Kubernetes](https://www.jaegertracing.io/docs/2.7/deployment/kubernetes/) has only:
  - link to the [Jaeger V2 Operator][jaeger-v2-operator] which has text for the "OpenTelemetry Collector Operator"
    - maybe this refers to the [OpenTelemetry Operator][opentelemetry-operator]?
  - link to [helm-charts v2 branch][jaeger-helm-charts-v2]
    - last updated 7 months ago, refers to `appVersion: 2.0.0-rc2`

The best thing I could find is the LinkedIn post [Jaeger v2 with OpenTelemetry on Kubernetes][linkedin-jaeger-v2].

[jaeger-v2-operator]: https://github.com/jaegertracing/jaeger-operator#jaeger-v2-operator
[jaeger-helm-charts-v2]: https://github.com/jaegertracing/helm-charts/tree/v2
[linkedin-jaeger-v2]: https://www.linkedin.com/pulse/jaeger-v2-opentelemetry-kubernetes-young-gyu-kim-7s00c/

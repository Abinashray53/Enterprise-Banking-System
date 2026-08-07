# Prometheus observability foundation

This phase adds Prometheus metrics collection for the consistently namespaced
banking services: payment, loan, fraud, notification, and audit. The service
manifests opt in through `prometheus.io/scrape` annotations and expose Spring
Boot Actuator metrics at `/actuator/prometheus`.

## What is included

- Kubernetes endpoint discovery, scoped to the `banking` namespace.
- Least-privilege service-discovery RBAC.
- Persistent Prometheus TSDB storage with a 15-day retention period.
- Availability and 5xx-rate alerting rules, viewable in the Prometheus UI.
- A one-command PowerShell deployment runner.

## Deploy

From the repository root in the VS Code PowerShell terminal:

```powershell
& ".\Kubernetes Foundation\Prometheus\run-prometheus.ps1"
kubectl -n monitoring port-forward service/prometheus 9090:9090
```

Open `http://localhost:9090/targets`. The five banking services should appear
under the `banking-services` job once their application pods are running.

The older customer-service manifests intentionally are not scraped yet because
they use conflicting namespaces. Normalizing that service into the `banking`
namespace is a separate migration task.

This is the metrics collection layer. Alertmanager routing, Grafana dashboards,
long-term object storage, and multi-replica high availability belong to the
subsequent observability phases.

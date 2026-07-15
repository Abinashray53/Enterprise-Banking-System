# Grafana dashboard foundation

Grafana is deployed in the `monitoring` namespace and automatically provisions
the in-cluster Prometheus data source plus an Enterprise Banking overview
dashboard. It depends on the Prometheus phase being deployed first.

## Deploy

Run this from the repository root in the VS Code PowerShell terminal:

```powershell
& ".\Kubernetes Foundation\Grafana\run-grafana.ps1"
kubectl -n monitoring port-forward service/grafana 3000:3000
```

The script securely prompts for an administrator password and creates the
`grafana-admin` Kubernetes Secret at deployment time. No real password is saved
in this repository. Sign in at `http://localhost:3000` with username `admin` and
the password you entered.

## Included dashboard

The **Enterprise Banking Platform Overview** dashboard shows service availability,
request rate, 5xx error rate, and active Prometheus alerts. It is provisioned as
code, so changes in the UI cannot overwrite the version-controlled definition.

For production, replace local Grafana storage with a managed database or an HA
deployment, inject credentials through a cloud secret manager, and publish the UI
only through an authenticated TLS ingress.

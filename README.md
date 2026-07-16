# Kafka event-streaming foundation

This phase supplies the Kafka dependency already referenced by the payment, loan,
fraud, notification, and audit services. Applications continue to use the stable
in-cluster bootstrap address `kafka:9092`.

## Architecture

- Three dedicated KRaft controllers maintain the metadata quorum.
- Three brokers retain banking event streams on individual persistent volumes.
- Internal client traffic enters through the `kafka` ClusterIP service; brokers
  advertise their stable StatefulSet DNS names for metadata discovery.
- The topic bootstrap Job is idempotent and creates the current service topics
  only after Kafka is reachable.
- Disruption budgets preserve a two-node quorum during voluntary maintenance.

## Deploy and verify

```powershell
.\Kubernetes Foundation\Kafka\run-kafka.ps1
```

The platform must provide a default `ReadWriteOnce` StorageClass. The manifests
intentionally do not hard-code an AWS, Azure, or GCP StorageClass so the same base
can run across the three clouds. The script checks for `kubectl`, cluster access,
and StorageClasses before applying the manifests. Use `-TimeoutMinutes 20` if your
cluster pulls images slowly.

## Operational guardrails

`KAFKA_CLUSTER_ID` is generated for this cluster and must never change once its
volumes are formatted. For a completely new cluster, generate a new ID before the
first deployment; for recovery, restore the original ID together with the Kafka
data volumes.

This foundation keeps the existing application contract of plaintext internal
Kafka traffic and restricts ingress to the `banking` namespace. It must not be
exposed outside the cluster. The next security-hardening phase should move clients
to TLS plus SASL or mTLS, with a secret manager and certificate rotation, before
any production deployment handling real banking data.

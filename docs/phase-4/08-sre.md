# Phase 4 - Step 8: SRE Documentation

## Objective

Define the SRE fundamentals for the deployed application: SLIs, SLOs, Error Budget, and the metrics used to decide a rollback.

---

## Application Context

- **Service:** Static web application served by nginx
- **Stack:** nginx + nginx-prometheus-exporter sidecar on K3s
- **Deployment:** 2 replicas, managed by Jenkins CI/CD pipeline
- **Exposure:** Internet → ALB → NGINX EC2 → K8s NodePort (30080)

---

## 1. SLI — Service Level Indicators

SLIs are the concrete metrics used to measure service health. For this application:

| SLI | Metric | Description |
|-----|--------|-------------|
| **Availability** | `rate(nginx_http_requests_total[5m]) > 0` | The service is responding to requests |
| **Throughput** | `rate(nginx_http_requests_total[5m])` | Requests per second being processed |
| **Saturation** | `nginx_connections_active` | Number of active connections — indicates load |
| **Pod health** | All pods in `devops-lab` showing `READY 2/2` | Both containers (app + sidecar) are running |

---

## 2. SLO — Service Level Objectives

SLOs set the target for each SLI over a defined time window.

| SLO | Target | Window |
|-----|--------|--------|
| **Availability** | 99% of the time the service is responding | 30 days |
| **Recovery time** | Pod recreated and ready in < 60 seconds | Per incident |
| **Throughput** | Capable of handling > 10 req/s without saturation | Validated in GameDay |
| **Deployment success** | New pods reach `Running 2/2` within 60s of deploy | Per deploy |

### What 99% availability means in practice

| Time window | Allowed downtime |
|-------------|-----------------|
| Per day     | 14.4 minutes |
| Per week    | 1.68 hours |
| Per month   | ~7.2 hours |
| Per year    | ~3.65 days |

---

## 3. Error Budget

The Error Budget is the allowed margin of failure derived from the SLO.

```
Error Budget = (1 - SLO) × total time in window
             = (1 - 0.99) × 43,200 minutes/month
             = 432 minutes/month  (~7.2 hours)
```

### How to use the Error Budget

| Budget remaining | Action |
|-----------------|--------|
| > 50% | Normal — deploy freely, run experiments |
| 25–50% | Caution — review recent incidents before deploying |
| < 25% | Freeze non-critical feature deployments, focus on stability |
| 0% (exhausted) | Full freeze until next budget window resets |

### GameDay impact on Error Budget

The incident simulated in Step 7 lasted approximately **20 seconds**.

```
Budget consumed = 20s / 43,200min = 0.00077%
Budget remaining = 99.99%
```

The self-healing capability of Kubernetes (replicas: 2) kept the Error Budget impact negligible.

---

## 4. Rollback Decision Metrics

These are the signals used to decide whether to roll back a deployment immediately after applying a new version.

**Observation window: first 5 minutes after deploy**

| Signal | Threshold | Action |
|--------|-----------|--------|
| Pod not reaching `Ready` | `0/2` for more than 60s | Immediate rollback |
| Pod restart count | Any restart in new pods | Immediate rollback |
| `nginx_connections_active` spike | > 3× baseline | Investigate → rollback if sustained |
| Loki shows repeated errors | Errors in `contenedor-web` logs post-deploy | Rollback |
| Throughput drops to 0 | `rate(nginx_http_requests_total[2m]) == 0` | Immediate rollback |

### Rollback command

```bash
kubectl rollout undo deployment/devops-app-deploy -n devops-lab
```

### Verify rollback

```bash
# Check rollout history
kubectl rollout history deployment/devops-app-deploy -n devops-lab

# Confirm pods are healthy after rollback
kubectl get pods -n devops-lab -w
```

---

## 5. Alerting vs Paging Thresholds

Not every alert requires waking someone up at 3am.

| Alert | Severity | Response |
|-------|----------|----------|
| CPU > 80% for 2 min | Warning | Investigate next business hour |
| Memory > 80% for 2 min | Warning | Investigate next business hour |
| Node Exporter down | Critical | Immediate — no metrics means blind operation |
| All pods restarting | Critical | Immediate — service likely degraded |
| Error Budget < 25% | Warning | Review in next team sync |

---

> [!NOTE]
> - These SLOs are defined for a learning environment running on a single-node t2.small cluster. In a production multi-node setup, higher targets (99.9% or above) would be appropriate, paired with actual persistent storage, multi-AZ deployments and more granular SLIs from application-level instrumentation.
> - The absence of response code metrics (2xx vs 5xx) is a known limitation of `stub_status`. For full request-level observability, the application would need a proper Prometheus client library integrated into the serving layer.

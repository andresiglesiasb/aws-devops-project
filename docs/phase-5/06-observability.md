# Phase 5 - Step 6: Observability

<div align="center">
<img src="../../diagrams/cluster.png" alt="Inside the K3s cluster — namespaces, ArgoCD sync, and the monitoring stack" width="90%">
<br><sub>Everything running inside the K3s cluster: <code>argocd</code>, <code>voting-app</code> and <code>monitoring</code> namespaces, and how they connect</sub>
</div>

---

## Objective

Extend the existing Prometheus + Grafana + Loki stack to cover the **voting-app microservices**. Out of the box the cluster only has *host-level* metrics (node-exporter) — none of the 5 microservices expose anything of their own. This step adds dedicated **sidecar exporters** for Redis and PostgreSQL (a second container running inside the same pod, sharing its network namespace) and sets up Grafana dashboards around them. `vote`, `result` and `worker` stay unmonitored at the container level — see the note below for why.

```
voting-app namespace
┌──────────────────────────────────────────────────────┐
│  vote pod     → no metrics exposed                    │
│  result pod   → no metrics exposed                    │
│  worker pod   → no metrics exposed                    │
│                                                        │
│  redis pod   [redis    + redis_exporter    sidecar] ──┤  :9121
│  db pod      [postgres + postgres_exporter sidecar] ──┘  :9187
└──────────────────────────────────────────────────────┘
                          │
              Prometheus (annotation scrape)
                          │
                       Grafana
```

---

## What already works without changes

| Source | Available metrics |
|--------|------------------|
| **node-exporter** | Host CPU, memory, disk, and network — for the whole node, not per container |

> [!NOTE]
> `cAdvisor` and `kube-state-metrics` are **not** actually wired up in this cluster: `k8s/monitoring/prometheus.yml` has no scrape job pointing at the kubelet's `/metrics/cadvisor` endpoint, and `kube-state-metrics` is never deployed (same caveat already noted in [phase-4/06-alertmanager.md](../phase-4/06-alertmanager.md)). So there is no per-container CPU/memory and no pod-restart data for any of the 5 microservices — only the node-wide numbers from node-exporter.
>
> `vote`, `result` and `worker` come straight from the [Docker Voting App](https://github.com/dockersamples/example-voting-app) and ship no Prometheus client library (`prometheus_client` / `prom-client` / `prometheus-net`) and no `/metrics` route — verified directly against the fork's `requirements.txt`, `package.json` and `Worker.csproj`. Adding annotations to them would do nothing without first instrumenting the application code, which is out of scope here.

Prometheus is configured to **autodiscover pods** via annotations. Any pod with `prometheus.io/scrape: "true"` in its metadata is scraped automatically on the port specified by `prometheus.io/port` — right now that only matches the **`redis-exporter`** and **`postgres-exporter`** sidecars added in steps B and C below. As sidecars they run inside the same pod as `redis`/`db`, so they reach the app over `localhost` (`localhost:6379` / `localhost:5432`) while exposing their own `/metrics` on `9121` / `9187` for Prometheus to scrape.

---

## Requirements

- Prometheus + Grafana running in the `monitoring` namespace (from previous phases).
- ArgoCD syncing the `example-voting-app-gitops` repository.
- SSH tunnel open to access Grafana.

---

## A. Access Grafana

Grafana is exposed as a NodePort on port **30300** of the node. Open a local tunnel:

```bash
ssh -fNL 3000:localhost:30300 k8s
```

Open `http://localhost:3000/grafana/` in the browser (default credentials: `admin` / `admin`, or whatever you set in previous phases).

---

## B. Add redis_exporter to the Redis pod

`redis_exporter` is deployed as a **sidecar** inside the same pod as Redis. It shares the network with the main container, so it connects to Redis at `localhost:6379`.

Edit `redis-deployment.yaml` in the GitOps repository to add the annotations and the sidecar:

**Before:**
```yaml
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - image: redis:alpine
        name: redis
```

**After:**
```yaml
  template:
    metadata:
      labels:
        app: redis
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9121"
    spec:
      containers:
      - image: redis:alpine
        name: redis
        ports:
        - containerPort: 6379
          name: redis
        volumeMounts:
        - mountPath: /data
          name: redis-data
      - name: redis-exporter
        image: oliver006/redis_exporter:latest
        ports:
        - containerPort: 9121
          name: metrics
        env:
        - name: REDIS_ADDR
          value: redis://localhost:6379
```

---

## C. Add postgres_exporter to the PostgreSQL pod

Same pattern — a sidecar inside the `db` pod, connecting to PostgreSQL at `localhost:5432`.

Edit `db-deployment.yaml`:

**Before:**
```yaml
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
      - image: postgres:15-alpine
        name: postgres
```

**After:**
```yaml
  template:
    metadata:
      labels:
        app: db
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9187"
    spec:
      containers:
      - image: postgres:15-alpine
        name: postgres
        env:
        - name: POSTGRES_USER
          value: postgres
        - name: POSTGRES_PASSWORD
          value: postgres
        ports:
        - containerPort: 5432
          name: postgres
        volumeMounts:
        - mountPath: /var/lib/postgresql/data
          name: db-data
      - name: postgres-exporter
        image: prometheuscommunity/postgres-exporter:latest
        ports:
        - containerPort: 9187
          name: metrics
        env:
        - name: DATA_SOURCE_NAME
          value: postgresql://postgres:postgres@localhost:5432/postgres?sslmode=disable
```

---

## D. Commit and push to the GitOps repository

```bash
cd ~/aws-devops-repos/example-voting-app-gitops
git add redis-deployment.yaml db-deployment.yaml
git commit -m "feat: add redis_exporter and postgres_exporter sidecars for observability"
git push origin main
```

ArgoCD detects the commit and applies the changes. The `redis` and `db` pods restart with the sidecar included:

```bash
ssh k8s "sudo kubectl get pods -n voting-app -w"
```

Wait until both pods show **2/2** in the `READY` column (main container + exporter):

```
NAME                   READY   STATUS    RESTARTS   AGE
db-xxx                 2/2     Running   0          30s
redis-xxx              2/2     Running   0          30s
result-xxx             1/1     Running   0          18h
vote-xxx               1/1     Running   0          18h
worker-xxx             1/1     Running   0          18h
```

![argocd-observability-sync](../../assets/phase5-argocd-observability.png)

---

## E. Verify Prometheus is scraping the exporters

Open Prometheus in the browser. Add the tunnel if not already open:

```bash
ssh -fNL 9090:localhost:9090 k8s
```

Go to `http://localhost:9090/targets` and look for the `kubernetes-pods` job. You should see entries for the `redis` and `db` pods in the `voting-app` namespace with status **UP**.

![prometheus-targets](../../assets/phase5-prometheus-targets.png)

Run a quick query at `http://localhost:9090/graph` to confirm:

```promql
redis_connected_clients{kubernetes_namespace="voting-app"}
```

```promql
pg_stat_database_numbackends{kubernetes_namespace="voting-app"}
```

---

## F. Grafana Dashboards

### F1. Redis Dashboard

1. In Grafana, go to **Dashboards → Import**
2. In the **Import via grafana.com** field, enter ID: **`763`**
3. Click **Load**
4. Under **Prometheus**, select your Prometheus datasource
5. Click **Import**

The dashboard shows used memory, commands per second, connected clients, and cache hits/misses.

### F2. PostgreSQL Dashboard

1. **Dashboards → Import** → ID: **`9628`**
2. Select the Prometheus datasource
3. Click **Import**

The dashboard shows active connections, transactions, database size, and locks.

### F3. Host metrics dashboard (CPU, memory, disk)

The Prometheus setup scrapes node-exporter but not cAdvisor or kube-state-metrics, so Kubernetes-specific dashboards (pod-level CPU/memory) are not available. Use the **Node Exporter Full** dashboard instead — it shows the full resource picture of the host running all 5 pods:

1. **Dashboards → Import** → ID: **`405`**
2. Select the Prometheus datasource → **Import**

Key panels to watch:
- **CPU Busy** — overall node CPU driven by all pods combined
- **RAM Used** — memory pressure from the full stack
- **System Load** — 1/5/15 min averages; sustained load > 2 on a 2-vCPU node means resource contention

![grafana-voting-app-dashboard](../../assets/phase5-grafana-dashboard.png)

---

## G. Existing alerts

Alertmanager is already configured from previous phases. With the new exporters active, you can add specific alerts for the voting-app by editing the `alertmanager-config` ConfigMap in the `monitoring` namespace.

Example alert for Redis with no connected clients:

```yaml
- alert: RedisNoClients
  expr: redis_connected_clients{kubernetes_namespace="voting-app"} == 0
  for: 2m
  labels:
    severity: warning
  annotations:
    summary: "No clients connected to Redis in voting-app"
```

---

## H. Full stack summary

| Component | Metrics | Logs |
|-----------|---------|------|
| `vote` | ❌ none — no `/metrics`, no client library | Promtail → Loki |
| `result` | ❌ none — no `/metrics`, no client library | Promtail → Loki |
| `worker` | ❌ none — no `/metrics`, no client library | Promtail → Loki |
| `redis` | redis_exporter sidecar (9121) | Promtail → Loki |
| `db` | postgres_exporter sidecar (9187) | Promtail → Loki |
| Host node | node-exporter (9100) — node-wide only, not per pod | — |

---

> [!NOTE]
> - `vote`, `result` and `worker` have **no metrics in Prometheus** — no scrape job in `prometheus.yml` targets cAdvisor, and the apps themselves expose no `/metrics` endpoint. The only signal available for them is logs (via Promtail/Loki) and their `Running`/`CrashLoopBackOff` status from `kubectl get pods`.
> - `redis_exporter` and `postgres_exporter` are official Prometheus community images, deployed as **sidecars** (a second container inside the same pod, sharing its network namespace via `localhost`). They require no changes to the application code — that's exactly why sidecars are used for `redis`/`db` instead of the in-process instrumentation `vote`/`result`/`worker` would need.
> - Promtail collects logs from all pods automatically and ships them to Loki. To view them in Grafana, use the Loki datasource and filter by `namespace="voting-app"`.

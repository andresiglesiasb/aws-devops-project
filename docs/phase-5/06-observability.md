# Phase 5 - Step 6: Observability

## Objective

Extend the existing Prometheus + Grafana + Loki stack to cover the **voting-app microservices**. The cluster already scrapes host and pod metrics — this step adds dedicated exporters for Redis and PostgreSQL, and sets up Grafana dashboards to visualise the full system state.

```
voting-app namespace
┌──────────────────────────────────────────────────────┐
│  vote pod     → cAdvisor  ─────────────────────────┐ │
│  result pod   → cAdvisor  ─────────────────────────┤ │
│  worker pod   → cAdvisor  ─────────────────────────┤ │
│                                                    │ │
│  redis pod    → redis_exporter  (port 9121) ───────┤ │
│  db pod       → postgres_exporter (port 9187) ─────┘ │
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
| **node-exporter** | Host CPU, memory, disk, and network |
| **cAdvisor** (kubelet) | CPU and memory per container — already includes all 5 voting-app pods |
| **kube-state-metrics** | Pod status, restarts, available replicas |

Prometheus is configured to **autodiscover pods** via annotations. Any pod with `prometheus.io/scrape: "true"` in its metadata is scraped automatically on the port specified by `prometheus.io/port`.

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
| `vote` | CPU/mem via cAdvisor | Promtail → Loki |
| `result` | CPU/mem via cAdvisor | Promtail → Loki |
| `worker` | CPU/mem via cAdvisor | Promtail → Loki |
| `redis` | redis_exporter (9121) | Promtail → Loki |
| `db` | postgres_exporter (9187) | Promtail → Loki |
| Host node | node-exporter (9100) | — |

---

> [!NOTE]
> - All 5 pods already have CPU and memory metrics available in Prometheus from the moment ArgoCD deployed them — cAdvisor scrapes them without any code changes.
> - `redis_exporter` and `postgres_exporter` are official Prometheus community images. They require no changes to the application code.
> - Promtail collects logs from all pods automatically and ships them to Loki. To view them in Grafana, use the Loki datasource and filter by `namespace="voting-app"`.

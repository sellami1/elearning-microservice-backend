Below is a complete set of K3s manifests that replicate your Docker Compose stack.  
**Prerequisites before applying:**

1. **Build & push your app images** – K3s cannot use `build:` contexts directly. Build each service and push to a registry (or import into k3s via `k3s ctr images import`).
   - `user-service` from `./backend/user-service`
   - `course-service` from `./backend/course-service`
   - `analytics-service` from `./backend/analytics-service`
   - `frontend` from `../elearning-microservice-platform-frontend`
2. **Replace the placeholder** in `02-configmap-init-sql.yaml` with your real `init.sql` content.
3. **Update image names** in the Deployment manifests from `:latest` to your actual registry/tag.
4. **Storage:** K3s ships with the `local-path` provisioner by default, so the PVCs will bind automatically.

---

### Quick start
```bash
# 1. Apply all manifests
kubectl apply -f 00-namespace.yaml \
              -f 01-secrets.yaml \
              -f 02-configmap-nginx.yaml \
              -f 02-configmap-init-sql.yaml \
              -f 03-pvcs.yaml \
              -f 04-mongodb.yaml \
              -f 05-postgres.yaml \
              -f 06-minio.yaml \
              -f 07-redis.yaml \
              -f 08-user-service.yaml \
              -f 09-course-service.yaml \
              -f 10-analytics-service.yaml \
              -f 11-frontend.yaml \
              -f 12-gateway.yaml

# 2. Verify
kubectl get pods -n learning-platform

# 3. Access the platform
# If using NodePort (default above):
#   http://<<k3s-node-ip>:30080
# If you want native port 80 on a single-node k3s setup, change the gateway Service to:
#   type: LoadBalancer   # k3s servicelb will bind node port 80 automatically
```

### Key design decisions
| Compose concept | K3s equivalent |
|---|---|
| `build:` contexts | Pre-built container images (set in each Deployment) |
| `depends_on` + health conditions | `initContainers` with `nc` (netcat) waits for DBs; K8s readiness probes prevent traffic to unready pods |
| `volumes:` | `PersistentVolumeClaim` (StatefulSets for DBs/MinIO, Deployment+PVC for Redis) |
| `ports:` host mappings | ClusterIP Services for internal traffic; only the Gateway is exposed via `NodePort`/`LoadBalancer` |
| `healthcheck` | Native `livenessProbe` + `readinessProbe` (TCP, HTTP, or exec) |
| Nginx config file | ConfigMap mounted at `/etc/nginx/nginx.conf` with `subPath` |
| `init.sql` | ConfigMap mounted into `/docker-entrypoint-initdb.d` |

If you switch the gateway Service to `type: LoadBalancer`, K3s’s built-in ServiceLB will expose port 80 on your node IP, giving you the exact same `localhost:80` experience as Docker Compose.
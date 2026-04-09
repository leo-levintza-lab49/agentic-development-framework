# Kubernetes Template Index

Complete reference of all available templates, their placeholders, and use cases.

## Core Kubernetes Templates

### 1. Deployment (`deployment.yaml.template`)

**Purpose**: Deploy stateless applications with multiple replicas

**Key Features**:
- Rolling update strategy
- Resource limits and requests
- Health probes (liveness and readiness)
- Environment variables
- Security context
- Volume mounts

**Required Placeholders**:
- `{{APP_NAME}}` - Application name
- `{{IMAGE}}` - Container image with tag
- `{{REPLICAS}}` - Number of replicas (e.g., 3)
- `{{CONTAINER_PORT}}` - Container port (e.g., 8080)

**Optional Placeholders**:
- `{{VERSION}}` - Application version for labels
- `{{IMAGE_PULL_POLICY}}` - IfNotPresent, Always, Never
- `{{ENVIRONMENT}}` - Environment name (dev, staging, prod)
- `{{LOG_LEVEL}}` - Logging level
- `{{CPU_REQUEST}}` - CPU request (e.g., 100m)
- `{{CPU_LIMIT}}` - CPU limit (e.g., 500m)
- `{{MEMORY_REQUEST}}` - Memory request (e.g., 256Mi)
- `{{MEMORY_LIMIT}}` - Memory limit (e.g., 1Gi)
- `{{LIVENESS_PATH}}` - Liveness probe HTTP path
- `{{READINESS_PATH}}` - Readiness probe HTTP path
- `{{RUN_AS_USER}}` - User ID to run as (e.g., 1000)
- `{{FS_GROUP}}` - File system group ID

**Use Cases**:
- Web applications
- API services
- Microservices
- Frontend applications

---

### 2. Service (`service.yaml.template`)

**Purpose**: Expose applications internally or externally

**Key Features**:
- ClusterIP, LoadBalancer, NodePort types
- Port mappings
- Service annotations
- Session affinity

**Required Placeholders**:
- `{{SERVICE_NAME}}` - Service name
- `{{APP_NAME}}` - App label for selector
- `{{PORT}}` - Service port
- `{{TARGET_PORT}}` - Target container port
- `{{SERVICE_TYPE}}` - ClusterIP, LoadBalancer, NodePort

**Optional Placeholders**:
- `{{ANNOTATIONS}}` - Service annotations
- `{{SESSION_AFFINITY}}` - ClientIP or None
- `{{ADDITIONAL_PORTS}}` - Additional port definitions

**Use Cases**:
- Internal service discovery
- Load balancing
- External access via LoadBalancer

---

### 3. ConfigMap (`configmap.yaml.template`)

**Purpose**: Store non-sensitive configuration data

**Key Features**:
- Multiple data formats (properties, JSON, YAML)
- Can be mounted as files or environment variables

**Required Placeholders**:
- `{{CONFIG_NAME}}` - ConfigMap name
- `{{APP_NAME}}` - App label
- `{{DATA}}` - Configuration data

**Data Format Examples**:
```yaml
app.properties: |
  database.host=db.example.com
  cache.ttl=3600

config.json: |
  {"feature_flags": {"new_ui": true}}

app.yaml: |
  server:
    port: 8080
```

**Use Cases**:
- Application configuration
- Feature flags
- Environment-specific settings

---

### 4. Secret (`secret.yaml.template`)

**Purpose**: Store sensitive data securely

**Key Features**:
- Base64 encoded values
- Alternative stringData format
- Support for TLS certificates

**Required Placeholders**:
- `{{SECRET_NAME}}` - Secret name
- `{{APP_NAME}}` - App label
- `{{DATA}}` - Base64 encoded data

**Common Data Types**:
- Database passwords
- API keys
- TLS certificates
- OAuth tokens

**Use Cases**:
- Database credentials
- API authentication
- TLS/SSL certificates
- Third-party service tokens

---

### 5. Ingress (`ingress.yaml.template`)

**Purpose**: Configure external HTTP(S) access to services

**Key Features**:
- AWS ALB annotations
- NGINX annotations
- TLS/SSL configuration
- Path-based routing
- Host-based routing

**Required Placeholders**:
- `{{INGRESS_NAME}}` - Ingress name
- `{{HOST}}` - Hostname (e.g., app.example.com)
- `{{PATHS}}` - Path routing rules
- `{{INGRESS_CLASS}}` - alb, nginx, etc.

**AWS ALB Specific**:
- `{{CERTIFICATE_ARN}}` - ACM certificate ARN
- `{{ALB_SCHEME}}` - internet-facing or internal
- `{{ALB_TARGET_TYPE}}` - ip or instance
- `{{HEALTH_CHECK_PATH}}` - Health check endpoint

**Use Cases**:
- External application access
- SSL/TLS termination
- Multiple services behind single domain
- Path-based routing

---

### 6. HPA (`hpa.yaml.template`)

**Purpose**: Automatically scale pods based on metrics

**Key Features**:
- CPU and memory metrics
- Custom metrics support
- Scale up/down policies
- Stabilization windows

**Required Placeholders**:
- `{{APP_NAME}}` - Target deployment name
- `{{MIN_REPLICAS}}` - Minimum replicas (e.g., 2)
- `{{MAX_REPLICAS}}` - Maximum replicas (e.g., 10)
- `{{CPU_TARGET_UTILIZATION}}` - Target CPU % (e.g., 70)
- `{{MEMORY_TARGET_UTILIZATION}}` - Target memory % (e.g., 80)

**Advanced Placeholders**:
- `{{SCALE_DOWN_STABILIZATION}}` - Wait time before scaling down
- `{{SCALE_UP_STABILIZATION}}` - Wait time before scaling up
- `{{CUSTOM_METRICS}}` - Custom metric definitions

**Use Cases**:
- Handle traffic spikes
- Optimize resource usage
- Cost optimization
- Performance management

---

### 7. StatefulSet (`statefulset.yaml.template`)

**Purpose**: Deploy stateful applications with persistent storage

**Key Features**:
- Stable network identities
- Persistent volume claims
- Ordered deployment/scaling
- Pod management policies

**Required Placeholders**:
- `{{APP_NAME}}` - StatefulSet name
- `{{SERVICE_NAME}}` - Headless service name
- `{{REPLICAS}}` - Number of replicas
- `{{IMAGE}}` - Container image
- `{{STORAGE_CLASS}}` - Storage class name
- `{{STORAGE_SIZE}}` - Storage size (e.g., 10Gi)
- `{{VOLUME_NAME}}` - Volume name
- `{{MOUNT_PATH}}` - Mount path in container

**Optional Placeholders**:
- `{{POD_MANAGEMENT_POLICY}}` - OrderedReady or Parallel
- `{{UPDATE_STRATEGY_TYPE}}` - RollingUpdate or OnDelete
- `{{ACCESS_MODE}}` - ReadWriteOnce, ReadWriteMany, etc.

**Use Cases**:
- Databases (PostgreSQL, MySQL, MongoDB)
- Message queues (Kafka, RabbitMQ)
- Distributed systems (Elasticsearch, Cassandra)
- Cache systems (Redis)

---

### 8. PersistentVolumeClaim (`pvc.yaml.template`)

**Purpose**: Request persistent storage for applications

**Required Placeholders**:
- `{{PVC_NAME}}` - PVC name
- `{{APP_NAME}}` - App label
- `{{STORAGE_CLASS}}` - Storage class (gp2, gp3, etc.)
- `{{STORAGE_SIZE}}` - Storage size (e.g., 8Gi)
- `{{ACCESS_MODE}}` - ReadWriteOnce, ReadWriteMany, etc.

**Access Modes**:
- `ReadWriteOnce` (RWO) - Single node read-write
- `ReadOnlyMany` (ROX) - Multiple nodes read-only
- `ReadWriteMany` (RWX) - Multiple nodes read-write
- `ReadWriteOncePod` (RWOP) - Single pod read-write

**Use Cases**:
- Database storage
- Application data persistence
- Shared file systems
- Log storage

---

### 9. Job (`job.yaml.template`)

**Purpose**: Run one-time or batch tasks to completion

**Required Placeholders**:
- `{{JOB_NAME}}` - Job name
- `{{IMAGE}}` - Container image
- `{{COMMAND}}` - Command to execute
- `{{BACKOFF_LIMIT}}` - Retry count (e.g., 3)

**Optional Placeholders**:
- `{{COMPLETIONS}}` - Number of successful completions
- `{{PARALLELISM}}` - Parallel execution count
- `{{TTL_SECONDS}}` - TTL after completion
- `{{ACTIVE_DEADLINE_SECONDS}}` - Max execution time
- `{{RESTART_POLICY}}` - Never or OnFailure

**Use Cases**:
- Database migrations
- Data processing
- Batch operations
- One-time tasks

---

### 10. CronJob (`cronjob.yaml.template`)

**Purpose**: Run jobs on a schedule

**Required Placeholders**:
- `{{CRONJOB_NAME}}` - CronJob name
- `{{CRON_SCHEDULE}}` - Cron expression (e.g., "0 2 * * *")
- `{{IMAGE}}` - Container image
- `{{COMMAND}}` - Command to execute

**Optional Placeholders**:
- `{{TIMEZONE}}` - Timezone for schedule
- `{{CONCURRENCY_POLICY}}` - Allow, Forbid, Replace
- `{{SUCCESSFUL_JOBS_HISTORY_LIMIT}}` - Job history to keep
- `{{FAILED_JOBS_HISTORY_LIMIT}}` - Failed job history

**Cron Schedule Examples**:
- `"*/15 * * * *"` - Every 15 minutes
- `"0 * * * *"` - Every hour
- `"0 2 * * *"` - Daily at 2 AM
- `"0 0 * * 0"` - Weekly on Sunday
- `"0 9 * * 1-5"` - Weekdays at 9 AM

**Use Cases**:
- Scheduled backups
- Report generation
- Data cleanup
- Health checks
- Metric collection

---

### 11. DaemonSet (`daemonset.yaml.template`)

**Purpose**: Run a pod on every (or selected) node

**Required Placeholders**:
- `{{DAEMONSET_NAME}}` - DaemonSet name
- `{{APP_NAME}}` - App label
- `{{IMAGE}}` - Container image
- `{{CONTAINER_NAME}}` - Container name

**Optional Placeholders**:
- `{{NODE_SELECTOR}}` - Node selection labels
- `{{TOLERATIONS}}` - Toleration for taints
- `{{HOST_NETWORK}}` - Use host network (true/false)
- `{{PRIVILEGED}}` - Run privileged (true/false)

**Use Cases**:
- Log collection (Fluentd, Filebeat)
- Monitoring agents (Prometheus Node Exporter)
- Network plugins
- Storage plugins
- Security agents

---

### 12. Namespace (`namespace.yaml.template`)

**Purpose**: Create namespace with resource quotas and limits

**Required Placeholders**:
- `{{NAMESPACE_NAME}}` - Namespace name
- `{{ENVIRONMENT}}` - Environment label
- `{{TEAM}}` - Team label

**ResourceQuota Placeholders**:
- `{{CPU_REQUESTS_QUOTA}}` - Total CPU requests
- `{{MEMORY_REQUESTS_QUOTA}}` - Total memory requests
- `{{CPU_LIMITS_QUOTA}}` - Total CPU limits
- `{{MEMORY_LIMITS_QUOTA}}` - Total memory limits
- `{{PODS_QUOTA}}` - Maximum pods
- `{{PVC_QUOTA}}` - Maximum PVCs

**Use Cases**:
- Environment isolation (dev, staging, prod)
- Team separation
- Resource management
- Multi-tenancy

---

## Helm Chart Templates

### Chart.yaml.template

**Purpose**: Helm chart metadata

**Required Placeholders**:
- `{{CHART_NAME}}` - Chart name
- `{{CHART_DESCRIPTION}}` - Chart description
- `{{VERSION}}` - Chart version (e.g., 0.1.0)
- `{{APP_VERSION}}` - Application version

**Optional Placeholders**:
- `{{KEYWORDS}}` - Search keywords
- `{{HOME_URL}}` - Project homepage
- `{{MAINTAINERS}}` - Maintainer list
- `{{DEPENDENCIES}}` - Chart dependencies

---

### values.yaml.template

**Purpose**: Default configuration values for Helm chart

**Key Sections**:
- Image configuration
- Replica count
- Service settings
- Ingress configuration
- Resource limits
- Autoscaling settings
- Security contexts
- Probes
- ConfigMap/Secret data

**Use Cases**:
- Default values for chart
- Environment-specific overrides
- Configuration management

---

### Helm Template Files (helm-templates/)

All Kubernetes resources with Helm templating syntax:
- `deployment.yaml.template` - Templated Deployment
- `service.yaml.template` - Templated Service
- `ingress.yaml.template` - Templated Ingress with conditionals
- `hpa.yaml.template` - Templated HPA with conditionals
- `configmap.yaml.template` - Templated ConfigMap
- `secret.yaml.template` - Templated Secret
- `serviceaccount.yaml.template` - Templated ServiceAccount
- `pdb.yaml.template` - Pod Disruption Budget
- `networkpolicy.yaml.template` - Network Policy
- `servicemonitor.yaml.template` - Prometheus ServiceMonitor
- `_helpers.tpl.template` - Helper functions and templates

**Key Features**:
- Values from values.yaml via `.Values`
- Conditional rendering with `{{ if }}`
- Helper function calls with `{{ include }}`
- Label and annotation management
- Automatic checksums for ConfigMap/Secret updates

---

## Utility Scripts

### generate-k8s-manifest.sh

**Purpose**: Generate Kubernetes manifests from templates

**Usage**:
```bash
./scripts/generate-k8s-manifest.sh -t deployment -c app-config.env -o deployment.yaml
```

**Features**:
- Placeholder replacement
- Configuration file loading
- Dry-run mode
- Batch generation

---

### validate-manifests.sh

**Purpose**: Validate Kubernetes manifests

**Usage**:
```bash
./scripts/validate-manifests.sh deployment.yaml
./scripts/validate-manifests.sh -d manifests/
```

**Features**:
- kubectl validation
- kubeval validation
- YAML syntax checking
- Common issue detection
- Strict mode

---

## Example Configurations

### production-values.yaml

Production-ready Helm values with:
- High availability (3+ replicas)
- Resource limits appropriate for production
- Pod disruption budgets
- Autoscaling enabled
- Network policies
- Security contexts
- Monitoring enabled

### staging-values.yaml

Cost-optimized staging configuration with:
- Lower replica counts
- Reduced resource limits
- Debug logging enabled
- Internal load balancer
- Simplified security settings

### app-config.env

Complete configuration file with all available placeholders for generating Kubernetes manifests.

---

## Quick Reference Matrix

| Template | Replicas | Storage | External Access | Use Case |
|----------|----------|---------|-----------------|----------|
| Deployment | Yes | No | Via Service/Ingress | Stateless apps |
| StatefulSet | Yes | Yes | Via Service | Stateful apps |
| DaemonSet | Per node | No | Via Service | Node-level tasks |
| Job | No | No | No | One-time tasks |
| CronJob | No | No | No | Scheduled tasks |
| Service | N/A | N/A | Can expose | Service discovery |
| Ingress | N/A | N/A | Yes | HTTP(S) routing |

---

## Placeholder Naming Conventions

- `{{ALL_CAPS}}` - Required values to be replaced
- Clear, descriptive names
- Consistent across templates
- Include units in name when applicable (e.g., `{{CPU_REQUEST}}`)

---

## Next Steps

1. Review [README.md](README.md) for detailed documentation
2. Check [QUICK_START.md](QUICK_START.md) for getting started
3. Explore [examples/](examples/) for configuration samples
4. Use [scripts/](scripts/) for automation

---

## Additional Resources

- [Kubernetes API Reference](https://kubernetes.io/docs/reference/kubernetes-api/)
- [Helm Chart Guide](https://helm.sh/docs/topics/charts/)
- [Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)

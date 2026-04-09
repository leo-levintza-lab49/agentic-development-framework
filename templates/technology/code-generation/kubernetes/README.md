# Kubernetes and Helm Chart Templates

Comprehensive collection of Kubernetes resource and Helm chart templates for rapid deployment configuration.

## Directory Structure

```
kubernetes/
├── deployment.yaml.template          # Standard Kubernetes Deployment
├── service.yaml.template             # Service (ClusterIP, LoadBalancer, NodePort)
├── configmap.yaml.template           # ConfigMap for application configuration
├── secret.yaml.template              # Secret for sensitive data
├── ingress.yaml.template             # Ingress with ALB/NGINX annotations
├── hpa.yaml.template                 # Horizontal Pod Autoscaler
├── statefulset.yaml.template         # StatefulSet for stateful applications
├── pvc.yaml.template                 # PersistentVolumeClaim
├── job.yaml.template                 # Batch Job
├── cronjob.yaml.template             # Scheduled CronJob
├── daemonset.yaml.template           # DaemonSet for node-level workloads
├── namespace.yaml.template           # Namespace with ResourceQuota and LimitRange
├── Chart.yaml.template               # Helm Chart metadata
├── values.yaml.template              # Helm default values
└── helm-templates/                   # Helm templated resources
    ├── deployment.yaml.template      # Helm templated deployment
    ├── service.yaml.template         # Helm templated service
    ├── ingress.yaml.template         # Helm templated ingress
    ├── hpa.yaml.template             # Helm templated HPA
    ├── serviceaccount.yaml.template  # Helm templated service account
    ├── configmap.yaml.template       # Helm templated ConfigMap
    ├── secret.yaml.template          # Helm templated Secret
    ├── pdb.yaml.template             # Pod Disruption Budget
    ├── networkpolicy.yaml.template   # Network Policy
    ├── servicemonitor.yaml.template  # Prometheus ServiceMonitor
    └── _helpers.tpl.template         # Helm helper functions
```

## Kubernetes Templates

### 1. Deployment (`deployment.yaml.template`)

Standard Kubernetes Deployment with:
- Configurable replicas and image
- Resource requests and limits
- Liveness and readiness probes
- Environment variables
- Security context
- Volume mounts

**Placeholders:**
- `{{APP_NAME}}`, `{{IMAGE}}`, `{{REPLICAS}}`
- `{{CPU_REQUEST}}`, `{{CPU_LIMIT}}`, `{{MEMORY_REQUEST}}`, `{{MEMORY_LIMIT}}`
- `{{LIVENESS_PATH}}`, `{{READINESS_PATH}}`
- `{{CONTAINER_PORT}}`, `{{ENVIRONMENT}}`

### 2. Service (`service.yaml.template`)

Kubernetes Service supporting ClusterIP, LoadBalancer, and NodePort:
- Port mappings
- Selector labels
- Service annotations

**Placeholders:**
- `{{SERVICE_NAME}}`, `{{APP_NAME}}`
- `{{SERVICE_TYPE}}`, `{{PORT}}`, `{{TARGET_PORT}}`

### 3. ConfigMap (`configmap.yaml.template`)

ConfigMap for application configuration:
- Supports multiple data formats (properties, JSON, YAML)
- Example data structures included

**Placeholders:**
- `{{CONFIG_NAME}}`, `{{APP_NAME}}`, `{{DATA}}`

### 4. Secret (`secret.yaml.template`)

Kubernetes Secret for sensitive data:
- Base64 encoded values
- Support for TLS certificates
- Alternative stringData format

**Placeholders:**
- `{{SECRET_NAME}}`, `{{APP_NAME}}`, `{{DATA}}`

### 5. Ingress (`ingress.yaml.template`)

Ingress resource with:
- AWS ALB and NGINX annotations
- TLS/SSL configuration
- Path-based routing
- Health check configuration

**Placeholders:**
- `{{INGRESS_NAME}}`, `{{HOST}}`, `{{PATHS}}`
- `{{CERTIFICATE_ARN}}`, `{{INGRESS_CLASS}}`

### 6. HPA (`hpa.yaml.template`)

Horizontal Pod Autoscaler with:
- CPU and memory metrics
- Custom metrics support
- Scale up/down policies
- Stabilization windows

**Placeholders:**
- `{{APP_NAME}}`, `{{MIN_REPLICAS}}`, `{{MAX_REPLICAS}}`
- `{{CPU_TARGET_UTILIZATION}}`, `{{MEMORY_TARGET_UTILIZATION}}`

### 7. StatefulSet (`statefulset.yaml.template`)

StatefulSet for stateful applications:
- Persistent volume claims
- Stable network identities
- Ordered deployment and scaling
- Pod management policies

**Placeholders:**
- `{{APP_NAME}}`, `{{SERVICE_NAME}}`, `{{REPLICAS}}`
- `{{VOLUME_NAME}}`, `{{STORAGE_SIZE}}`, `{{STORAGE_CLASS}}`

### 8. Job (`job.yaml.template`)

Batch Job for one-time tasks:
- Backoff limits and retry logic
- Parallelism and completions
- TTL after finished
- Active deadline

**Placeholders:**
- `{{JOB_NAME}}`, `{{IMAGE}}`, `{{COMMAND}}`

### 9. CronJob (`cronjob.yaml.template`)

Scheduled CronJob:
- Cron schedule configuration
- Timezone support
- Concurrency policies
- Job history limits

**Placeholders:**
- `{{CRONJOB_NAME}}`, `{{CRON_SCHEDULE}}`
- `{{CONCURRENCY_POLICY}}`, `{{TIMEZONE}}`

## Helm Chart Templates

### Chart Structure

Complete Helm chart with:
- **Chart.yaml**: Chart metadata and dependencies
- **values.yaml**: Default configuration values
- **templates/**: Templated Kubernetes resources

### Key Features

1. **Helper Functions** (`_helpers.tpl`):
   - Consistent naming conventions
   - Label generation
   - Selector labels
   - Service account names

2. **Conditional Resources**:
   - Ingress (enabled/disabled)
   - Autoscaling (enabled/disabled)
   - ConfigMap/Secret (enabled/disabled)
   - ServiceMonitor for Prometheus

3. **Security Best Practices**:
   - Non-root containers
   - Read-only root filesystem
   - Security contexts
   - Pod security standards

4. **Advanced Features**:
   - Pod Disruption Budget
   - Network Policies
   - Service Monitors
   - Resource quotas

## Usage Examples

### Using Kubernetes Templates

```bash
# Replace placeholders in deployment template
sed -e 's/{{APP_NAME}}/my-app/g' \
    -e 's/{{IMAGE}}/nginx:latest/g' \
    -e 's/{{REPLICAS}}/3/g' \
    deployment.yaml.template > deployment.yaml

# Apply to cluster
kubectl apply -f deployment.yaml
```

### Using Helm Chart

```bash
# Create new Helm chart from templates
mkdir my-app-chart
cp Chart.yaml.template my-app-chart/Chart.yaml
cp values.yaml.template my-app-chart/values.yaml
mkdir my-app-chart/templates
cp helm-templates/*.template my-app-chart/templates/

# Customize values.yaml
vim my-app-chart/values.yaml

# Install chart
helm install my-app ./my-app-chart

# Upgrade with custom values
helm upgrade my-app ./my-app-chart -f custom-values.yaml

# Dry run to see generated manifests
helm template my-app ./my-app-chart
```

## Best Practices

### Resource Management
- Always set resource requests and limits
- Use HPA for dynamic scaling
- Configure Pod Disruption Budgets for high availability

### Health Checks
- Implement liveness probes to restart unhealthy pods
- Use readiness probes to control traffic routing
- Set appropriate timeouts and thresholds

### Security
- Run containers as non-root
- Use read-only root filesystems
- Apply Pod Security Standards
- Scan images for vulnerabilities

### Configuration
- Use ConfigMaps for non-sensitive configuration
- Store secrets in Kubernetes Secrets or external secret managers
- Separate environment-specific values

### Networking
- Use Network Policies to restrict pod-to-pod traffic
- Configure proper Ingress rules
- Use Services for stable networking

### Monitoring
- Add ServiceMonitor for Prometheus
- Include proper labels for observability
- Configure logging agents (DaemonSet)

## Placeholder Reference

### Common Placeholders

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `{{APP_NAME}}` | Application name | `my-app` |
| `{{IMAGE}}` | Container image | `nginx:1.21` |
| `{{REPLICAS}}` | Number of replicas | `3` |
| `{{CPU_REQUEST}}` | CPU request | `100m` |
| `{{CPU_LIMIT}}` | CPU limit | `500m` |
| `{{MEMORY_REQUEST}}` | Memory request | `128Mi` |
| `{{MEMORY_LIMIT}}` | Memory limit | `512Mi` |
| `{{ENVIRONMENT}}` | Environment name | `production` |
| `{{PORT}}` | Service port | `80` |
| `{{CONTAINER_PORT}}` | Container port | `8080` |

## Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)

## Contributing

When adding new templates:
1. Follow Kubernetes API conventions
2. Include comprehensive placeholders
3. Add security best practices
4. Document all configuration options
5. Provide usage examples

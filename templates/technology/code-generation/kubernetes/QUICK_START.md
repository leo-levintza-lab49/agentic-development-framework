# Kubernetes Templates - Quick Start Guide

Get started with Kubernetes and Helm chart templates in minutes.

## Table of Contents

1. [Quick Setup](#quick-setup)
2. [Generate Your First Manifest](#generate-your-first-manifest)
3. [Deploy with Helm](#deploy-with-helm)
4. [Common Use Cases](#common-use-cases)
5. [Troubleshooting](#troubleshooting)

## Quick Setup

### Prerequisites

```bash
# Check if kubectl is installed
kubectl version --client

# Check if helm is installed (optional)
helm version

# Check cluster access
kubectl cluster-info
```

### Directory Structure

```
kubernetes/
├── deployment.yaml.template          # Core templates
├── service.yaml.template
├── ingress.yaml.template
├── hpa.yaml.template
├── Chart.yaml.template               # Helm chart templates
├── values.yaml.template
├── examples/                         # Example configurations
│   ├── app-config.env
│   ├── production-values.yaml
│   └── staging-values.yaml
├── scripts/                          # Utility scripts
│   ├── generate-k8s-manifest.sh
│   └── validate-manifests.sh
└── helm-templates/                   # Helm template files
```

## Generate Your First Manifest

### Method 1: Simple Substitution

```bash
# Copy template
cp deployment.yaml.template my-app-deployment.yaml

# Edit placeholders manually
vim my-app-deployment.yaml

# Replace placeholders
sed -i '' 's/{{APP_NAME}}/my-app/g' my-app-deployment.yaml
sed -i '' 's/{{IMAGE}}/nginx:1.21/g' my-app-deployment.yaml
sed -i '' 's/{{REPLICAS}}/3/g' my-app-deployment.yaml

# Apply to cluster
kubectl apply -f my-app-deployment.yaml
```

### Method 2: Using Generator Script

```bash
# 1. Copy and customize configuration
cp examples/app-config.env my-app.env
vim my-app.env

# 2. Generate manifest
./scripts/generate-k8s-manifest.sh \
  --template deployment \
  --config my-app.env \
  --output my-app-deployment.yaml

# 3. Validate manifest
./scripts/validate-manifests.sh my-app-deployment.yaml

# 4. Apply to cluster
kubectl apply -f my-app-deployment.yaml
```

### Method 3: Generate All Manifests

```bash
# Generate all common manifests
./scripts/generate-k8s-manifest.sh --config my-app.env

# This creates:
# - manifests/deployment.yaml
# - manifests/service.yaml
# - manifests/configmap.yaml
# - manifests/ingress.yaml
# - manifests/hpa.yaml

# Apply all
kubectl apply -f manifests/
```

## Deploy with Helm

### Create Helm Chart

```bash
# 1. Create chart directory
mkdir -p my-app-chart/templates

# 2. Copy Helm templates
cp Chart.yaml.template my-app-chart/Chart.yaml
cp values.yaml.template my-app-chart/values.yaml
cp helm-templates/*.template my-app-chart/templates/

# 3. Rename templates (remove .template extension)
cd my-app-chart/templates
for file in *.template; do mv "$file" "${file%.template}"; done
cd ../..

# 4. Customize Chart.yaml
sed -i '' 's/{{CHART_NAME}}/my-app/g' my-app-chart/Chart.yaml
sed -i '' 's/{{CHART_DESCRIPTION}}/My Application/g' my-app-chart/Chart.yaml
sed -i '' 's/{{VERSION}}/0.1.0/g' my-app-chart/Chart.yaml
```

### Deploy with Helm

```bash
# Development deployment
helm install my-app ./my-app-chart \
  --set image.repository=my-registry/my-app \
  --set image.tag=develop

# Production deployment
helm install my-app ./my-app-chart \
  --values examples/production-values.yaml

# Staging deployment
helm install my-app-staging ./my-app-chart \
  --values examples/staging-values.yaml \
  --namespace staging
```

### Manage Helm Releases

```bash
# List releases
helm list

# Get release status
helm status my-app

# Upgrade release
helm upgrade my-app ./my-app-chart \
  --set image.tag=v1.2.3

# Rollback release
helm rollback my-app

# Uninstall release
helm uninstall my-app
```

## Common Use Cases

### 1. Deploy Simple Web Application

```bash
# Create configuration
cat > web-app.env <<EOF
APP_NAME=web-app
IMAGE=nginx:alpine
REPLICAS=2
CONTAINER_PORT=80
CPU_REQUEST=50m
MEMORY_REQUEST=64Mi
CPU_LIMIT=200m
MEMORY_LIMIT=256Mi
SERVICE_NAME=web-app-service
SERVICE_TYPE=LoadBalancer
PORT=80
TARGET_PORT=80
EOF

# Generate and deploy
./scripts/generate-k8s-manifest.sh -c web-app.env -t deployment
./scripts/generate-k8s-manifest.sh -c web-app.env -t service
kubectl apply -f manifests/deployment.yaml
kubectl apply -f manifests/service.yaml

# Check status
kubectl get pods -l app=web-app
kubectl get service web-app-service
```

### 2. Deploy Stateful Application (Database)

```bash
# Use StatefulSet template
cat > database.env <<EOF
APP_NAME=postgres
IMAGE=postgres:14
REPLICAS=1
CONTAINER_PORT=5432
STORAGE_CLASS=gp3
STORAGE_SIZE=20Gi
SERVICE_NAME=postgres
EOF

# Generate StatefulSet
./scripts/generate-k8s-manifest.sh -c database.env -t statefulset
kubectl apply -f manifests/statefulset.yaml
```

### 3. Deploy with Autoscaling

```bash
# Generate deployment and HPA
./scripts/generate-k8s-manifest.sh -c my-app.env -t deployment
./scripts/generate-k8s-manifest.sh -c my-app.env -t hpa

# Apply
kubectl apply -f manifests/deployment.yaml
kubectl apply -f manifests/hpa.yaml

# Monitor autoscaling
kubectl get hpa -w
```

### 4. Schedule Cron Jobs

```bash
# Create cron job configuration
cat > backup-job.env <<EOF
CRONJOB_NAME=database-backup
CRON_SCHEDULE="0 2 * * *"
IMAGE=backup-tool:latest
COMMAND='["/backup.sh"]'
EOF

# Generate and deploy
./scripts/generate-k8s-manifest.sh -c backup-job.env -t cronjob
kubectl apply -f manifests/cronjob.yaml
```

### 5. Deploy with Ingress

```bash
# Configure ingress
cat > ingress.env <<EOF
INGRESS_NAME=app-ingress
APP_NAME=my-app
HOST=app.example.com
SERVICE_NAME=my-app-service
PORT=80
INGRESS_CLASS=nginx
CERTIFICATE_ARN=arn:aws:acm:region:account:certificate/id
EOF

# Generate and deploy
./scripts/generate-k8s-manifest.sh -c ingress.env -t ingress
kubectl apply -f manifests/ingress.yaml

# Check ingress
kubectl get ingress
```

## Validation and Testing

### Validate Manifests

```bash
# Validate single file
./scripts/validate-manifests.sh deployment.yaml

# Validate all in directory
./scripts/validate-manifests.sh -d manifests/

# Strict validation
./scripts/validate-manifests.sh -s deployment.yaml
```

### Dry Run Deployment

```bash
# Test without applying
kubectl apply -f deployment.yaml --dry-run=client

# Server-side dry run
kubectl apply -f deployment.yaml --dry-run=server
```

### Diff Before Apply

```bash
# Show what will change
kubectl diff -f deployment.yaml

# With Helm
helm diff upgrade my-app ./my-app-chart
```

## Monitoring Deployments

```bash
# Watch deployment progress
kubectl rollout status deployment/my-app

# Get deployment history
kubectl rollout history deployment/my-app

# Check pod logs
kubectl logs -l app=my-app --tail=100 -f

# Describe pod for debugging
kubectl describe pod -l app=my-app

# Get events
kubectl get events --sort-by=.metadata.creationTimestamp
```

## Troubleshooting

### Common Issues

#### 1. ImagePullBackOff

```bash
# Check image pull secrets
kubectl get secret
kubectl describe pod <pod-name>

# Create image pull secret
kubectl create secret docker-registry my-registry-secret \
  --docker-server=myregistry.azurecr.io \
  --docker-username=<username> \
  --docker-password=<password>
```

#### 2. CrashLoopBackOff

```bash
# Check logs
kubectl logs <pod-name> --previous

# Check resource limits
kubectl describe pod <pod-name> | grep -A5 "Limits"

# Check startup probes
kubectl describe pod <pod-name> | grep -A10 "Liveness\|Readiness"
```

#### 3. Pending Pods

```bash
# Check node resources
kubectl describe nodes

# Check pod events
kubectl describe pod <pod-name>

# Check PVC status
kubectl get pvc
```

#### 4. Service Not Reachable

```bash
# Check service endpoints
kubectl get endpoints <service-name>

# Check pod labels match service selector
kubectl get pods --show-labels

# Test service from within cluster
kubectl run -it --rm debug --image=busybox --restart=Never -- wget -O- <service-name>
```

### Debug Commands

```bash
# Get all resources
kubectl get all -l app=my-app

# Port forward for local testing
kubectl port-forward service/my-app 8080:80

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/sh

# Copy files to/from pod
kubectl cp <pod-name>:/path/to/file ./local-file
kubectl cp ./local-file <pod-name>:/path/to/file

# Get resource YAML
kubectl get deployment my-app -o yaml

# Edit live resource
kubectl edit deployment my-app
```

## Best Practices

1. **Always set resource limits**
   - Prevents resource exhaustion
   - Enables proper scheduling

2. **Use health checks**
   - Liveness probes for restarting unhealthy pods
   - Readiness probes for traffic management

3. **Version your images**
   - Avoid `:latest` tag
   - Use semantic versioning

4. **Use ConfigMaps and Secrets**
   - Separate configuration from code
   - Never hardcode credentials

5. **Enable autoscaling**
   - Handle traffic spikes automatically
   - Optimize resource usage

6. **Implement pod disruption budgets**
   - Maintain availability during updates
   - Prevent too many pods going down

7. **Use namespaces**
   - Organize resources by environment
   - Apply resource quotas

8. **Label everything**
   - Makes filtering and monitoring easier
   - Enables better organization

## Next Steps

- Read the full [README.md](README.md) for detailed documentation
- Check [examples/](examples/) for more configuration examples
- Explore Helm chart features in [helm-templates/](helm-templates/)
- Learn about Kubernetes best practices
- Set up CI/CD pipelines for automated deployments

## Additional Resources

- [Kubernetes Official Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Kubernetes Patterns](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/)

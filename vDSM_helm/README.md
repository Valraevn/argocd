# vDSM Helm Chart

Virtual Deduplication Storage Manager (vDSM) Helm chart for Kubernetes clusters, specifically designed for Talos Linux clusters with NFS storage support.

## Overview

This Helm chart deploys vDSM with the following features:
- NFS storage integration
- Configurable resource limits
- Security best practices
- Health checks and monitoring
- ArgoCD integration ready

## Prerequisites

- Kubernetes cluster (1.19+)
- Helm 3.0+
- NFS server accessible from the cluster
- ArgoCD (for GitOps deployment)

## NFS Storage Configuration

The chart is pre-configured to use the NFS share:
- **Server**: `10.1.1.2`
- **Path**: `/mnt/user/Talos`
- **Protocol**: NFSv4
- **Mount Options**: Optimized for performance and reliability

## Quick Start

### 1. Add the Helm Repository (if using external repo)

```bash
helm repo add vdsm https://your-helm-repo.com
helm repo update
```

### 2. Install the Chart

```bash
# Create namespace
kubectl create namespace vdsm

# Install with default values
helm install vdsm ./vDSM_helm -n vdsm

# Install with custom values
helm install vdsm ./vDSM_helm -n vdsm \
  --set nfs.server=10.1.1.2 \
  --set nfs.path=/mnt/user/Talos \
  --set image.repository=your-registry/vdsm
```

### 3. Verify Installation

```bash
kubectl get pods -n vdsm
kubectl get svc -n vdsm
kubectl get pvc -n vdsm
```

## ArgoCD Deployment

### 1. Update the Application Manifest

Edit `app.yaml` and update:
- `repoURL`: Your Git repository URL
- `image.repository`: Your container registry path
- `image.tag`: Desired image tag

### 2. Apply the Application

```bash
kubectl apply -f app.yaml
```

### 3. Monitor Deployment

```bash
argocd app get vdsm
argocd app logs vdsm
```

## Configuration

### Values.yaml

Key configuration options:

```yaml
# NFS Configuration
nfs:
  enabled: true
  server: "10.1.1.2"
  path: "/mnt/user/Talos"
  mountOptions:
    - "nfsvers=4"
    - "hard"
    - "nointr"

# Storage Configuration
persistence:
  enabled: true
  size: 100Gi
  accessMode: ReadWriteMany

# Resource Limits
resources:
  limits:
    cpu: 2000m
    memory: 4Gi
  requests:
    cpu: 500m
    memory: 1Gi
```

### Environment Variables

The chart supports the following environment variables:
- `NFS_SERVER`: NFS server IP/hostname
- `NFS_PATH`: NFS mount path
- `LOG_LEVEL`: Logging level (info, debug, warn, error)
- `NODE_ENV`: Environment (production, development)

## Storage

### StorageClass

The chart creates a custom StorageClass `vdsm-nfs` with:
- **Provisioner**: `k8s.io/minikube-hostpath` (for testing)
- **Reclaim Policy**: Retain
- **Volume Binding**: Immediate

### Persistent Volumes

- **Type**: NFS
- **Access Mode**: ReadWriteMany
- **Default Size**: 100Gi
- **Mount Path**: `/data`

## Security

### Pod Security Context

- Non-root user execution
- Read-only root filesystem
- Dropped capabilities
- Security context constraints

### Service Account

- Dedicated service account
- Configurable annotations
- RBAC ready

## Monitoring & Health Checks

### Health Endpoints

- **Liveness**: `/health`
- **Readiness**: `/ready`

### Probe Configuration

```yaml
livenessProbe:
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3

readinessProbe:
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3
```

## Scaling

### Horizontal Pod Autoscaler

```yaml
hpa:
  enabled: true
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80
```

### Manual Scaling

```bash
kubectl scale deployment vdsm -n vdsm --replicas=3
```

## Troubleshooting

### Common Issues

1. **NFS Mount Failures**
   ```bash
   kubectl describe pod <pod-name> -n vdsm
   kubectl logs <pod-name> -n vdsm
   ```

2. **Storage Class Issues**
   ```bash
   kubectl get storageclass
   kubectl describe storageclass vdsm-nfs
   ```

3. **Permission Issues**
   ```bash
   kubectl describe pvc <pvc-name> -n vdsm
   kubectl describe pv <pv-name>
   ```

### Debug Commands

```bash
# Check pod status
kubectl get pods -n vdsm -o wide

# Check events
kubectl get events -n vdsm --sort-by='.lastTimestamp'

# Check logs
kubectl logs -f deployment/vdsm -n vdsm

# Check storage
kubectl get pv,pvc -n vdsm
```

## Upgrading

### Helm Upgrade

```bash
helm upgrade vdsm ./vDSM_helm -n vdsm
```

### ArgoCD Sync

```bash
argocd app sync vdsm
```

## Uninstalling

### Helm Uninstall

```bash
helm uninstall vdsm -n vdsm
kubectl delete namespace vdsm
```

### ArgoCD Delete

```bash
argocd app delete vdsm
```

## Customization

### Custom Values

Create a custom `values.yaml`:

```yaml
# Custom values
image:
  repository: my-registry/vdsm
  tag: "v1.2.3"

nfs:
  server: "192.168.1.100"
  path: "/storage/talos"

resources:
  limits:
    cpu: 4000m
    memory: 8Gi
```

### Custom Templates

Add custom templates in the `templates/` directory:
- `ingress.yaml` for custom ingress rules
- `service-monitor.yaml` for Prometheus monitoring
- `network-policy.yaml` for network policies

## Support

For issues and questions:
- Check the troubleshooting section
- Review Kubernetes events and logs
- Verify NFS connectivity and permissions
- Ensure proper resource allocation

## License

This chart is licensed under the MIT License.

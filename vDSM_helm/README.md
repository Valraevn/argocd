# vDSM Helm Chart

This Helm chart deploys vDSM (Virtual Desktop Session Manager) on Kubernetes with support for both local host storage and persistent volume claims.

## Features

- **Local Storage Support**: Mount host directories directly into pods for high-performance local storage
- **PVC Support**: Traditional Kubernetes persistent volume claims for cloud-native deployments
- **ArgoCD Ready**: Designed for GitOps deployments with ArgoCD
- **Configurable Resources**: Adjustable CPU and memory limits/requests

## Storage Configuration

### Local Host Storage (Recommended for Talos clusters)

To use local storage from the host's `/var/vdsm` directory:

```yaml
storage:
  type: "hostPath"
  hostPath: "/var/vdsm"
```

**Important**: Ensure the `/var/vdsm` directory exists on your Talos nodes and has appropriate permissions.

### Persistent Volume Claims

For traditional Kubernetes storage:

```yaml
storage:
  type: "pvc"
  storageClass: "standard"
  size: 16Gi
  volumeMode: Filesystem
```

## Prerequisites

1. **For Local Storage**: Ensure `/var/vdsm` directory exists on your Talos nodes
2. **Kubernetes Cluster**: v1.19+ with StatefulSet support
3. **ArgoCD**: For GitOps deployment (optional)

## Installation

### Using Helm directly:

```bash
helm install vdsm ./vDSM_helm \
  --set storage.type=hostPath \
  --set storage.hostPath=/var/vdsm
```

### Using ArgoCD:

The chart includes an `argocd-application.yaml` file for GitOps deployment.

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of vDSM replicas | `3` |
| `storage.type` | Storage type: `hostPath` or `pvc` | `hostPath` |
| `storage.hostPath` | Host path for local storage | `/var/vdsm` |
| `storage.size` | Storage size for PVC mode | `16Gi` |
| `config.dataDir` | Data directory inside container | `/var/lib/vdsm` |

## Talos Linux Considerations

When deploying on Talos Linux:

1. **Host Path**: The `/var/vdsm` directory must exist on each node
2. **Permissions**: Ensure proper file permissions for the vDSM service
3. **Node Affinity**: Pods will be scheduled on nodes with the required host path
4. **Local Storage**: Provides better performance for local workloads

## Troubleshooting

### Pods stuck in Pending state:
- Check if `/var/vdsm` directory exists on your Talos nodes
- Verify node selector and affinity settings
- Check resource requests vs. available node resources

### Storage access issues:
- Verify host path permissions
- Check if the directory is accessible from the container
- Review security context settings if applicable

## Security Notes

- Host path volumes bypass Kubernetes security policies
- Ensure proper file permissions on the host directory
- Consider using security contexts for additional isolation

# vDSM Helm Chart

This Helm chart deploys vDSM (Virtual Desktop Session Manager) on Kubernetes with support for both local host storage and persistent volume claims.

## Features

- **Local Storage Support**: Mount host directories directly into pods for high-performance local storage
- **PVC Support**: Traditional Kubernetes persistent volume claims for cloud-native deployments
- **ArgoCD Ready**: Designed for GitOps deployments with ArgoCD
- **Configurable Resources**: Adjustable CPU and memory limits/requests
- **Pod Security Standards Compliant**: Built-in security contexts and PSP support

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

## Security Configuration

### Pod Security Standards Compliance

The chart includes built-in security configurations to comply with Pod Security Standards:

```yaml
security:
  runAsUser: 1000
  runAsGroup: 1000
  fsGroup: 1000
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: false
```

### Pod Security Policy (PSP)

When using `hostPath` storage, the chart automatically creates:
- A Pod Security Policy allowing hostPath volumes
- Required RBAC resources (ClusterRole, ClusterRoleBinding)
- ServiceAccount with proper permissions

## Prerequisites

1. **For Local Storage**: Ensure `/var/vdsm` directory exists on your Talos nodes
2. **Kubernetes Cluster**: v1.19+ with StatefulSet support
3. **ArgoCD**: For GitOps deployment (optional)
4. **Pod Security Policy**: If using older Kubernetes versions (< 1.25)

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
| `security.runAsUser` | User ID to run as | `1000` |
| `security.runAsGroup` | Group ID to run as | `1000` |
| `security.fsGroup` | File system group | `1000` |

## Talos Linux Considerations

When deploying on Talos Linux:

1. **Host Path**: The `/var/vdsm` directory must exist on each node
2. **Permissions**: Ensure proper file permissions for the vDSM service
3. **Node Affinity**: Pods will be scheduled on nodes with the required host path
4. **Local Storage**: Provides better performance for local workloads
5. **Security**: Uses non-root user (UID 1000) for enhanced security

## Troubleshooting

### Pods stuck in Pending state:
- Check if `/var/vdsm` directory exists on your Talos nodes
- Verify node selector and affinity settings
- Check resource requests vs. available node resources
- Ensure Pod Security Policy allows hostPath volumes

### Security policy violations:
- Verify the PSP is created and bound to the ServiceAccount
- Check that security contexts are properly configured
- Ensure the cluster has PSP admission controller enabled (if using PSP)

### Storage access issues:
- Verify host path permissions
- Check if the directory is accessible from the container
- Review security context settings if applicable

## Security Notes

- Host path volumes bypass Kubernetes security policies
- Ensure proper file permissions on the host directory
- Security contexts are configured to run as non-root user
- Pod Security Policy automatically created for hostPath storage
- Seccomp and AppArmor profiles set to runtime/default

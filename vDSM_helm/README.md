# vDSM Helm Chart

A Helm chart for deploying Virtual DSM (vDSM) on Kubernetes clusters with NFS storage support.

## Features

- **NFS Storage**: Configurable NFS storage with CSI provisioner support
- **Security Compliant**: Baseline security policy compliant configuration
- **Resource Management**: Configurable resource limits and requests
- **Service Account**: Dedicated service account for security

## Prerequisites

- Kubernetes cluster with NFS CSI provisioner installed
- NFS server accessible from the cluster
- Baseline or higher Pod Security Standards enabled

## Configuration

### Storage Configuration

The chart uses NFS CSI provisioner for dynamic volume provisioning:

```yaml
storage:
  nfs:
    server: "10.1.1.2"        # Your NFS server IP
    path: "/mnt/user/Talos"    # NFS share path
  accessModes:
    - ReadWriteMany            # Multiple pods can access simultaneously
  resources:
    requests:
      storage: "16Gi"          # Storage size
  storageClassName: "nfs"     # Storage class name
```

### Security Configuration

The chart is configured to comply with baseline Pod Security Standards:

- **No privileged mode**: Container runs without privileged access
- **Limited capabilities**: Only NET_ADMIN capability is added
- **Non-root user**: Container runs as user 1000
- **No hostPath volumes**: Uses emptyDir for temporary storage

### Resource Configuration

```yaml
resources:
  requests:
    memory: "2Gi"
    cpu: "1000m"
  limits:
    memory: "8Gi"
    cpu: "4000m"
```

## Installation

1. **Add the Helm repository** (if applicable)
2. **Update values.yaml** with your NFS server details
3. **Install the chart**:
   ```bash
   helm install vdsm ./vDSM_helm
   ```

## Important Notes

- **NFS CSI Required**: Ensure `nfs.csi.k8s.io` provisioner is installed
- **Security Compliance**: This chart follows baseline security standards
- **Storage**: Uses dynamic provisioning - no manual PV creation needed
- **Capabilities**: Limited to NET_ADMIN for network management only

## Troubleshooting

### Storage Issues
- Verify NFS CSI provisioner is running
- Check NFS server connectivity
- Ensure storage class exists and is properly configured

### Security Issues
- If you need additional capabilities, consider using a more permissive security policy
- Host device access requires privileged mode (not recommended for production)

## Values Reference

See `values.yaml` for all configurable options and their default values.
# vDSM Helm Chart

This Helm chart deploys Virtual DSM (vDSM) containers in Kubernetes. vDSM is a containerized version of Synology DSM that provides NAS functionality.

## Prerequisites

- Kubernetes cluster with NFS storage support
- Nodes with KVM virtualization support (`/dev/kvm` device)
- NFS server accessible from the cluster
- Storage class named `nfs` configured

## Features

- **KVM Acceleration**: Full hardware virtualization support
- **Network Management**: Bridge networking with NET_ADMIN capabilities
- **Persistent Storage**: NFS-based persistent volume claims
- **Resource Management**: Configurable CPU and memory limits
- **High Availability**: Configurable replica count

## Configuration

### Storage Configuration

```yaml
storage:
  nfs:
    server: "10.1.1.2"  # NFS server IP
    path: "/mnt/user/Talos"  # NFS export path
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: "16Gi"
```

### Container Configuration

```yaml
image:
  repository: "vdsm/virtual-dsm"
  tag: "latest"
  pullPolicy: IfNotPresent

replicaCount: 1
```

### Security Context

The container runs with privileged mode and additional capabilities:
- `NET_ADMIN`: For network bridge creation
- `SYS_ADMIN`: For system administration tasks
- `SYS_RAWIO`: For raw I/O operations

### Resource Limits

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

1. Update the `values.yaml` with your NFS server details
2. Ensure the `nfs` storage class is available
3. Deploy the chart:

```bash
helm install vdsm ./vDSM_helm
```

## Troubleshooting

### Common Issues

1. **"Failed to create bridge"**: Ensure the container has NET_ADMIN capability (already configured)
2. **"KVM acceleration is not available"**: Ensure `/dev/kvm` is accessible on the host node
3. **Port mapping issues**: Check that the service is properly configured

### Node Requirements

- KVM virtualization support enabled in BIOS
- `/dev/kvm` device accessible
- Sufficient CPU and memory resources

## Notes

- The container runs in privileged mode for KVM and networking access
- Host device mounts are required for proper functionality
- NFS storage is recommended for persistent data
- Consider resource limits based on your workload requirements
# vDSM Helm Chart

A Helm chart for deploying Virtual DSM (vDSM) on Kubernetes clusters with NFS storage support.

## Features

- **NFS Storage**: Configurable NFS storage with CSI provisioner support
- **Security Compliant**: Baseline security policy compliant configuration
- **Resource Management**: Configurable resource limits and requests
- **Service Account**: Dedicated service account for security
- **Permission Management**: Init container ensures proper file permissions for nginx

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

The chart is configured to comply with **baseline** Pod Security Standards:

- **No privileged mode**: Container runs without privileged access
- **Minimal capabilities**: Only essential capabilities for nginx operation (CHOWN, SETGID, SETUID)
- **Root user**: Container runs as root (required by vDSM scripts)
- **No hostPath volumes**: Uses emptyDir for temporary storage
- **Init container**: Sets proper file permissions before main container starts

**⚠️ Important Security Note**: The baseline configuration includes minimal capabilities needed for nginx to function properly. The container runs as root because vDSM scripts require root privileges.

### Init Container

The chart includes an init container that:
- Creates necessary nginx directories
- Sets proper ownership (user 33:33 - typically www-data)
- Sets appropriate permissions (755) for nginx operation

This prevents the "chown failed: Operation not permitted" error that can occur when nginx tries to manage its directories.

### Alternative Security Configuration

If you need additional capabilities for full vDSM functionality, you can use a more permissive configuration. Edit `values.yaml` and uncomment the alternative security context:

```yaml
# Alternative security context for users who need additional capabilities
# Note: This requires a more permissive Pod Security Standard (privileged)
securityContext:
  privileged: true
  capabilities:
    add:
    - NET_ADMIN
    - SYS_ADMIN
    - SYS_RAWIO
```

**⚠️ Warning**: Using privileged mode requires your cluster to allow the `privileged` Pod Security Standard, which may not be available in all environments.

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
3. **Choose security level**:
   - **Baseline (default)**: Maximum security, limited functionality, runs as root, includes nginx permissions
   - **Privileged**: Full functionality, requires permissive security policy
4. **Install the chart**:
   ```bash
   helm install vdsm ./vDSM_helm
   ```

## Important Notes

- **NFS CSI Required**: Ensure `nfs.csi.k8s.io` provisioner is installed
- **Security Compliance**: Default configuration follows baseline security standards
- **Storage**: Uses dynamic provisioning - no manual PV creation needed
- **Capabilities**: Minimal capabilities for nginx operation (CHOWN, SETGID, SETUID)
- **Root User**: Container runs as root (required by vDSM)
- **Init Container**: Automatically sets up nginx permissions

## Troubleshooting

### Storage Issues
- Verify NFS CSI provisioner is running
- Check NFS server connectivity
- Ensure storage class exists and is properly configured

### Security Issues
- **Baseline mode**: Limited functionality but maximum security, runs as root, includes nginx permissions
- **Privileged mode**: Full functionality but requires permissive security policy
- If you need host device access, use the alternative security context

### Functionality Limitations in Baseline Mode
- Network bridge creation may not work (requires NET_ADMIN)
- System administration tasks may be limited (requires SYS_ADMIN)
- Raw I/O operations may not work (requires SYS_RAWIO)

### Common Issues
- **"Script must be executed with root privileges"**: Fixed - container runs as root
- **"chown failed: Operation not permitted"**: Fixed - init container sets proper permissions
- **CrashLoopBackOff**: Check logs for other errors after fixing root privileges and permissions

## Values Reference

See `values.yaml` for all configurable options and their default values. The file includes both baseline and privileged security configurations for your convenience.
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
  mountPath: "/opt/vdsm"      # Container mount path
```

### Security Configuration

The chart provides **two security modes** to choose from:

#### 1. Baseline Mode (Default) - Maximum Security, Limited Functionality

```yaml
securityContext:
  privileged: false
  capabilities:
    add:
    - CHOWN
    - SETGID
    - SETUID
    - DAC_OVERRIDE
    - FOWNER
  runAsNonRoot: false
  runAsUser: 0
  runAsGroup: 0
  fsGroup: 0
```

**What works:**
- ✅ DSM installation and basic functionality
- ✅ Nginx web interface
- ✅ File operations and storage access
- ✅ Baseline security compliance

**What doesn't work:**
- ❌ TUN device access (network virtualization)
- ❌ KVM device access (hardware acceleration)
- ❌ Full network bridge functionality
- ❌ Optimal performance

#### 2. Privileged Mode - Full Functionality, Requires Privileged Security Policy

```yaml
securityContext:
  privileged: true
  capabilities:
    add:
    - NET_ADMIN       # For TUN device access
    - SYS_ADMIN       # For KVM device access
    - CHOWN
    - SETGID
    - SETUID
    - DAC_OVERRIDE
    - FOWNER
```

**What works:**
- ✅ Everything from baseline mode
- ✅ TUN device access (full networking)
- ✅ KVM device access (hardware acceleration)
- ✅ Optimal performance and functionality

**Requirements:**
- ❌ Cluster must allow "privileged" Pod Security Standard
- ❌ May not be available in all environments

### Init Container

The chart includes init containers that:
- **Storage setup**: Creates directories with proper permissions
- **Nginx setup**: Prepares nginx directories and log files
- **Permission management**: Ensures proper file access

## Installation

1. **Add the Helm repository** (if applicable)
2. **Update values.yaml** with your NFS server details
3. **Choose security level**:
   - **Baseline (default)**: Maximum security, limited functionality
   - **Privileged**: Full functionality, requires permissive security policy
4. **Install the chart**:
   ```bash
   helm install vdsm ./vDSM_helm
   ```

## Important Notes

- **NFS CSI Required**: Ensure `nfs.csi.k8s.io` provisioner is installed
- **Security Compliance**: Default configuration follows baseline security standards
- **Storage**: Uses dynamic provisioning - no manual PV creation needed
- **Capabilities**: Only baseline-compliant capabilities by default
- **Root User**: Container runs as root (required by vDSM)
- **Init Container**: Automatically sets up nginx permissions

## Trade-offs and Recommendations

### For Production/Strict Security
- **Use baseline mode** (default)
- Accept limited functionality for maximum security
- vDSM will work but with reduced performance

### For Development/Full Functionality
- **Use privileged mode** if your cluster allows it
- Get full TUN/KVM access and optimal performance
- Requires more permissive security policy

### For Testing
- **Start with baseline mode** to verify basic functionality
- **Upgrade to privileged mode** if you need full features

## Troubleshooting

### Storage Issues
- Verify NFS CSI provisioner is running
- Check NFS server connectivity
- Ensure storage class exists and is properly configured

### Security Issues
- **Baseline mode**: Limited functionality but maximum security
- **Privileged mode**: Full functionality but requires permissive security policy

### Functionality Limitations in Baseline Mode
- Network bridge creation may not work (requires NET_ADMIN)
- Hardware acceleration unavailable (requires KVM device)
- Some advanced networking features disabled

### Common Issues
- **"Script must be executed with root privileges"**: Fixed - container runs as root
- **"chown failed: Operation not permitted"**: Fixed - init container sets proper permissions
- **"TUN device is missing"**: Expected in baseline mode - use privileged mode for full functionality
- **"KVM acceleration is not available"**: Expected in baseline mode - use privileged mode for full performance

## Values Reference

See `values.yaml` for all configurable options and their default values. The file includes both baseline and privileged security configurations for your convenience.
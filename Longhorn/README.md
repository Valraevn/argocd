# Longhorn Helm Chart for Talos Linux

This Helm chart deploys Longhorn distributed block storage system optimized for Talos Linux clusters.

## Overview

Longhorn provides persistent block storage for Kubernetes workloads. This chart is specifically configured for Talos Linux clusters with proper node selectors, tolerations, and storage paths.

## Prerequisites

- Kubernetes 1.21+
- Talos Linux cluster with worker nodes
- Helm 3.0+
- Nodes labeled with `node-role.kubernetes.io/worker=true`
- Control plane nodes labeled with `node-role.kubernetes.io/control-plane=true`

## Talos-Specific Considerations

### Node Labels
- Worker nodes must be labeled: `node-role.kubernetes.io/worker=true`
- Control plane nodes must be labeled: `node-role.kubernetes.io/control-plane=true`

### Storage Paths
- Default data path: `/var/lib/longhorn`
- Kubelet root directory: `/var/lib/kubelet`

### Node Selectors
- Longhorn manager and driver components run on worker nodes
- UI components run on control plane nodes
- System-managed components use control plane node selector

## Installation

1. Add the Longhorn repository:
```bash
helm repo add longhorn https://charts.longhorn.io
helm repo update
```

2. Install the chart:
```bash
helm install longhorn ./ArgoCD/Helm/Longhorn \
  --namespace longhorn-system \
  --create-namespace
```

## Configuration

### Key Settings

- **Replica Count**: Default 3 replicas for high availability
- **Data Path**: `/var/lib/longhorn` (Talos-compatible)
- **Node Drain Policy**: `block-if-contains-last-replica`
- **V2 Data Engine**: Enabled for better performance

### Storage Classes

The chart creates a default storage class `longhorn` with:
- Replica count: 3
- Default data path: `/var/lib/longhorn`
- Soft anti-affinity for replicas

## Post-Installation

1. Verify all pods are running:
```bash
kubectl get pods -n longhorn-system
```

2. Check storage classes:
```bash
kubectl get storageclass
```

3. Access the UI:
```bash
kubectl port-forward -n longhorn-system svc/longhorn-frontend 8080:80
```

## Troubleshooting

### Common Issues

1. **Pods not scheduling**: Check node labels and tolerations
2. **Storage not provisioning**: Verify CSI driver is running
3. **Volume attachment failures**: Check kubelet root directory path

### Logs

```bash
# Manager logs
kubectl logs -n longhorn-system -l app=longhorn-manager

# CSI driver logs
kubectl logs -n longhorn-system -l app=longhorn-csi-plugin
```

## Uninstallation

```bash
helm uninstall longhorn -n longhorn-system
kubectl delete namespace longhorn-system
```

## Support

- [Longhorn Documentation](https://longhorn.io/docs/)
- [Talos Linux Documentation](https://www.talos.dev/)
- [GitHub Issues](https://github.com/longhorn/longhorn/issues)

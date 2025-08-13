# VDSM Helm Chart

This Helm chart deploys the VDSM application on a Kubernetes cluster. It is designed to work seamlessly with a Talos cluster and utilizes an NFS share for persistent storage.

## Prerequisites

- A running Talos cluster.
- Helm installed on your local machine.
- Access to an NFS server at `10.1.1.2` with the share mounted at `/mnt/user/Talos`.

## Installation

To install the VDSM Helm chart, follow these steps:

1. Add the Helm repository (if applicable):
   ```bash
   helm repo add <repository-name> <repository-url>
   ```

2. Install the chart using the following command:
   ```bash
   helm install <release-name> ./vdsm-helm-chart
   ```

3. Verify the installation:
   ```bash
   helm list
   ```

## Configuration

You can customize the deployment by modifying the `values.yaml` file. The following parameters can be configured:

- `replicaCount`: Number of replicas for the VDSM deployment.
- `image.repository`: The container image repository for the VDSM application.
- `image.tag`: The container image tag.
- `service.type`: The type of service to create (e.g., ClusterIP, NodePort).
- `service.port`: The port that the service will expose.

## Persistent Storage

This chart uses a PersistentVolumeClaim (PVC) to request storage from the NFS share. The PVC is configured to use the following settings:

- NFS Server: `10.1.1.2`
- NFS Path: `/mnt/user/Talos`
- Access Modes: ReadWriteMany

## Uninstallation

To uninstall the VDSM Helm chart, run the following command:
```bash
helm uninstall <release-name>
```

## License

This project is licensed under the MIT License. See the LICENSE file for details.
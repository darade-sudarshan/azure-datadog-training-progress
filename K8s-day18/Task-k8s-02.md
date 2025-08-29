# Task K8s-02: Kubernetes Architecture and Components

## Overview
This task covers the comprehensive Kubernetes architecture, explaining the function of each component, all controllers, and etcd backup procedures. Understanding the architecture is crucial for effective cluster management and troubleshooting.

## Table of Contents
1. [Kubernetes Architecture Overview](#kubernetes-architecture-overview)
2. [Control Plane Components](#control-plane-components)
3. [Node Components](#node-components)
4. [Kubernetes Controllers](#kubernetes-controllers)
5. [etcd Backup and Restore](#etcd-backup-and-restore)
6. [Networking Components](#networking-components)
7. [Add-ons and Extensions](#add-ons-and-extensions)

## Kubernetes Architecture Overview

Kubernetes follows a master-worker architecture with the following high-level components:

```
┌─────────────────────────────────────────────────────────────┐
│                    KUBERNETES CLUSTER                       │
├─────────────────────────────────────────────────────────────┤
│                   CONTROL PLANE                            │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │   API       │ │  SCHEDULER  │ │ CONTROLLER  │          │
│  │   SERVER    │ │             │ │  MANAGER    │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
│  ┌─────────────┐ ┌─────────────┐                          │
│  │    etcd     │ │ CLOUD       │                          │
│  │             │ │ CONTROLLER  │                          │
│  └─────────────┘ └─────────────┘                          │
├─────────────────────────────────────────────────────────────┤
│                    WORKER NODES                            │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ NODE 1                                                  ││
│  │ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐       ││
│  │ │ KUBELET │ │ KUBE-   │ │CONTAINER│ │  PODS   │       ││
│  │ │         │ │ PROXY   │ │ RUNTIME │ │         │       ││
│  │ └─────────┘ └─────────┘ └─────────┘ └─────────┘       ││
│  └─────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────┐│
│  │ NODE 2                                                  ││
│  │ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐       ││
│  │ │ KUBELET │ │ KUBE-   │ │CONTAINER│ │  PODS   │       ││
│  │ │         │ │ PROXY   │ │ RUNTIME │ │         │       ││
│  │ └─────────┘ └─────────┘ └─────────┘ └─────────┘       ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

## Control Plane Components

### 1. API Server (kube-apiserver)

**Function**: The central management entity that exposes the Kubernetes API and serves as the front-end for the control plane.

**Key Responsibilities**:
- Validates and configures API objects
- Serves REST operations
- Provides authentication and authorization
- Acts as the gateway for all administrative tasks

**Configuration**:
```yaml
# API Server configuration example
apiVersion: v1
kind: Pod
metadata:
  name: kube-apiserver
spec:
  containers:
  - name: kube-apiserver
    image: k8s.gcr.io/kube-apiserver:v1.28.0
    command:
    - kube-apiserver
    - --advertise-address=192.168.1.100
    - --allow-privileged=true
    - --authorization-mode=Node,RBAC
    - --client-ca-file=/etc/kubernetes/pki/ca.crt
    - --enable-admission-plugins=NodeRestriction
    - --etcd-servers=https://127.0.0.1:2379
    - --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt
    - --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key
    - --secure-port=6443
```

**Health Check**:
```bash
# Check API server status
kubectl get componentstatuses
curl -k https://localhost:6443/healthz
```

### 2. etcd

**Function**: Consistent and highly-available key-value store used as Kubernetes' backing store for all cluster data.

**Key Responsibilities**:
- Stores cluster state and configuration
- Maintains consistency across the cluster
- Provides watch functionality for state changes
- Handles leader election for control plane components

**Configuration**:
```yaml
# etcd configuration
apiVersion: v1
kind: Pod
metadata:
  name: etcd
spec:
  containers:
  - name: etcd
    image: k8s.gcr.io/etcd:3.5.9-0
    command:
    - etcd
    - --advertise-client-urls=https://192.168.1.100:2379
    - --cert-file=/etc/kubernetes/pki/etcd/server.crt
    - --client-cert-auth=true
    - --data-dir=/var/lib/etcd
    - --initial-advertise-peer-urls=https://192.168.1.100:2380
    - --initial-cluster=master=https://192.168.1.100:2380
    - --key-file=/etc/kubernetes/pki/etcd/server.key
    - --listen-client-urls=https://127.0.0.1:2379,https://192.168.1.100:2379
    - --listen-peer-urls=https://192.168.1.100:2380
    - --name=master
    - --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt
    - --peer-client-cert-auth=true
    - --peer-key-file=/etc/kubernetes/pki/etcd/peer.key
    - --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
    - --snapshot-count=10000
    - --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
```

### 3. Scheduler (kube-scheduler)

**Function**: Watches for newly created Pods with no assigned node and selects a node for them to run on.

**Key Responsibilities**:
- Resource-aware scheduling
- Affinity and anti-affinity rules
- Taints and tolerations
- Quality of Service (QoS) considerations

**Scheduling Process**:
1. **Filtering**: Eliminates nodes that don't meet requirements
2. **Scoring**: Ranks remaining nodes based on scoring functions
3. **Binding**: Assigns Pod to the highest-scoring node

**Configuration**:
```yaml
# Scheduler configuration
apiVersion: kubescheduler.config.k8s.io/v1beta3
kind: KubeSchedulerConfiguration
profiles:
- schedulerName: default-scheduler
  plugins:
    score:
      enabled:
      - name: NodeResourcesFit
      - name: NodeAffinity
      - name: PodTopologySpread
  pluginConfig:
  - name: NodeResourcesFit
    args:
      scoringStrategy:
        type: LeastAllocated
```

### 4. Controller Manager (kube-controller-manager)

**Function**: Runs controller processes that regulate the state of the cluster.

**Key Controllers**:
- Node Controller
- Replication Controller
- Endpoints Controller
- Service Account & Token Controllers

**Configuration**:
```yaml
# Controller Manager configuration
apiVersion: v1
kind: Pod
metadata:
  name: kube-controller-manager
spec:
  containers:
  - name: kube-controller-manager
    image: k8s.gcr.io/kube-controller-manager:v1.28.0
    command:
    - kube-controller-manager
    - --bind-address=127.0.0.1
    - --cluster-cidr=10.244.0.0/16
    - --cluster-name=kubernetes
    - --cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt
    - --cluster-signing-key-file=/etc/kubernetes/pki/ca.key
    - --kubeconfig=/etc/kubernetes/controller-manager.conf
    - --leader-elect=true
    - --service-cluster-ip-range=10.96.0.0/12
```

### 5. Cloud Controller Manager

**Function**: Embeds cloud-specific control logic and links the cluster into the cloud provider's API.

**Key Responsibilities**:
- Node Controller (cloud-specific)
- Route Controller
- Service Controller
- Volume Controller

## Node Components

### 1. Kubelet

**Function**: Primary node agent that runs on each node and ensures containers are running in Pods.

**Key Responsibilities**:
- Pod lifecycle management
- Container health monitoring
- Resource monitoring and reporting
- Volume mounting
- Network setup

**Configuration**:
```yaml
# Kubelet configuration
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
address: 0.0.0.0
port: 10250
readOnlyPort: 10255
cgroupDriver: systemd
clusterDNS:
- 10.96.0.10
clusterDomain: cluster.local
failSwapOn: false
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
authorization:
  mode: Webhook
```

### 2. Kube-proxy

**Function**: Network proxy that maintains network rules on nodes and enables communication to Pods.

**Key Responsibilities**:
- Service discovery and load balancing
- Network rule management
- Traffic forwarding
- Connection tracking

**Proxy Modes**:
- **iptables**: Default mode using iptables rules
- **IPVS**: High-performance mode using IPVS
- **userspace**: Legacy mode (deprecated)

**Configuration**:
```yaml
# Kube-proxy configuration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
bindAddress: 0.0.0.0
clientConnection:
  kubeconfig: /var/lib/kube-proxy/kubeconfig.conf
clusterCIDR: 10.244.0.0/16
mode: iptables
iptables:
  masqueradeAll: false
  masqueradeBit: 14
  minSyncPeriod: 0s
  syncPeriod: 30s
```

### 3. Container Runtime

**Function**: Software responsible for running containers.

**Supported Runtimes**:
- **containerd**: Industry-standard container runtime
- **CRI-O**: Lightweight container runtime for Kubernetes
- **Docker**: Traditional container runtime (deprecated in K8s 1.24+)

**Container Runtime Interface (CRI)**:
```bash
# Check container runtime
kubectl get nodes -o wide

# Inspect runtime on node
crictl info
crictl ps
crictl images
```

## Kubernetes Controllers

### 1. Deployment Controller

**Function**: Manages ReplicaSets and provides declarative updates to Pods.

**Key Features**:
- Rolling updates and rollbacks
- Scaling applications
- Pause and resume deployments

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
```

### 2. ReplicaSet Controller

**Function**: Ensures a specified number of Pod replicas are running at any given time.

**Key Features**:
- Pod replication
- Self-healing capabilities
- Label-based Pod selection

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-replicaset
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
```

### 3. StatefulSet Controller

**Function**: Manages stateful applications with stable network identities and persistent storage.

**Key Features**:
- Ordered deployment and scaling
- Stable network identifiers
- Persistent storage claims

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql-statefulset
spec:
  serviceName: mysql
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "password"
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: mysql-storage
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

### 4. DaemonSet Controller

**Function**: Ensures all (or some) nodes run a copy of a Pod.

**Key Features**:
- Node-level services
- System daemons
- Monitoring agents

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd-daemonset
spec:
  selector:
    matchLabels:
      app: fluentd
  template:
    metadata:
      labels:
        app: fluentd
    spec:
      containers:
      - name: fluentd
        image: fluentd:v1.14
        volumeMounts:
        - name: varlog
          mountPath: /var/log
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
```

### 5. Job Controller

**Function**: Manages Pods that run to completion.

**Key Features**:
- Batch processing
- One-time tasks
- Parallel execution

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: batch-job
spec:
  completions: 3
  parallelism: 2
  template:
    spec:
      containers:
      - name: worker
        image: busybox
        command: ["sh", "-c", "echo Processing item && sleep 30"]
      restartPolicy: Never
```

### 6. CronJob Controller

**Function**: Manages time-based Jobs.

**Key Features**:
- Scheduled execution
- Cron-like syntax
- Job history management

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-cronjob
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: backup-tool:latest
            command: ["sh", "-c", "backup-script.sh"]
          restartPolicy: OnFailure
```

### 7. Service Controller

**Function**: Manages Service endpoints and load balancing.

**Service Types**:
- **ClusterIP**: Internal cluster communication
- **NodePort**: External access via node ports
- **LoadBalancer**: Cloud provider load balancer
- **ExternalName**: DNS CNAME mapping

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
```

### 8. Ingress Controller

**Function**: Manages external access to services via HTTP/HTTPS routes.

**Key Features**:
- HTTP/HTTPS routing
- SSL termination
- Virtual hosting

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
```

### 9. Namespace Controller

**Function**: Manages namespace lifecycle and resource quotas.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: production-quota
  namespace: production
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    pods: "10"
```

### 10. Node Controller

**Function**: Manages node lifecycle and health monitoring.

**Key Responsibilities**:
- Node registration
- Health monitoring
- Eviction management
- Taints and tolerations

```bash
# Check node status
kubectl get nodes
kubectl describe node <node-name>

# Cordon and drain node
kubectl cordon <node-name>
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
```

## etcd Backup and Restore

### Prerequisites

```bash
# Install etcdctl
ETCD_VER=v3.5.9
curl -L https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/
sudo mv /tmp/etcd-${ETCD_VER}-linux-amd64/etcdctl /usr/local/bin/
```

### Backup Procedures

#### 1. Manual Backup

```bash
# Set environment variables
export ETCDCTL_API=3
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key

# Create backup
sudo etcdctl snapshot save /backup/etcd-snapshot-$(date +%Y%m%d-%H%M%S).db \
  --endpoints=https://127.0.0.1:2379

# Verify backup
sudo etcdctl snapshot status /backup/etcd-snapshot-$(date +%Y%m%d-%H%M%S).db
```

#### 2. Automated Backup Script

```bash
#!/bin/bash
# etcd-backup.sh

# Configuration
BACKUP_DIR="/backup/etcd"
RETENTION_DAYS=7
ETCD_ENDPOINTS="https://127.0.0.1:2379"

# Environment variables
export ETCDCTL_API=3
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key

# Create backup directory
mkdir -p $BACKUP_DIR

# Create backup
BACKUP_FILE="$BACKUP_DIR/etcd-snapshot-$(date +%Y%m%d-%H%M%S).db"
etcdctl snapshot save $BACKUP_FILE --endpoints=$ETCD_ENDPOINTS

# Verify backup
if etcdctl snapshot status $BACKUP_FILE > /dev/null 2>&1; then
    echo "Backup successful: $BACKUP_FILE"
else
    echo "Backup failed: $BACKUP_FILE"
    exit 1
fi

# Cleanup old backups
find $BACKUP_DIR -name "etcd-snapshot-*.db" -mtime +$RETENTION_DAYS -delete

echo "Backup completed and old backups cleaned up"
```

#### 3. CronJob for Automated Backup

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: etcd-backup
  namespace: kube-system
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          hostNetwork: true
          containers:
          - name: etcd-backup
            image: k8s.gcr.io/etcd:3.5.9-0
            command:
            - /bin/sh
            - -c
            - |
              export ETCDCTL_API=3
              etcdctl snapshot save /backup/etcd-snapshot-$(date +%Y%m%d-%H%M%S).db \
                --endpoints=https://127.0.0.1:2379 \
                --cacert=/etc/kubernetes/pki/etcd/ca.crt \
                --cert=/etc/kubernetes/pki/etcd/server.crt \
                --key=/etc/kubernetes/pki/etcd/server.key
            volumeMounts:
            - name: etcd-certs
              mountPath: /etc/kubernetes/pki/etcd
              readOnly: true
            - name: backup-storage
              mountPath: /backup
          volumes:
          - name: etcd-certs
            hostPath:
              path: /etc/kubernetes/pki/etcd
          - name: backup-storage
            hostPath:
              path: /backup/etcd
          restartPolicy: OnFailure
          nodeSelector:
            node-role.kubernetes.io/control-plane: ""
          tolerations:
          - key: node-role.kubernetes.io/control-plane
            operator: Exists
            effect: NoSchedule
```

### Restore Procedures

#### 1. Stop etcd and API Server

```bash
# Move current etcd data
sudo mv /var/lib/etcd /var/lib/etcd.backup

# Stop kubelet (which will stop static pods)
sudo systemctl stop kubelet
```

#### 2. Restore from Backup

```bash
# Restore etcd data
sudo etcdctl snapshot restore /backup/etcd-snapshot-20231201-020000.db \
  --data-dir=/var/lib/etcd \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Fix ownership
sudo chown -R etcd:etcd /var/lib/etcd
```

#### 3. Start Services

```bash
# Start kubelet
sudo systemctl start kubelet

# Verify cluster status
kubectl get nodes
kubectl get pods --all-namespaces
```

#### 4. Complete Restore Script

```bash
#!/bin/bash
# etcd-restore.sh

BACKUP_FILE=$1
if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup-file>"
    exit 1
fi

# Environment variables
export ETCDCTL_API=3
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key

echo "Starting etcd restore process..."

# Backup current data
echo "Backing up current etcd data..."
sudo mv /var/lib/etcd /var/lib/etcd.backup-$(date +%Y%m%d-%H%M%S)

# Stop kubelet
echo "Stopping kubelet..."
sudo systemctl stop kubelet

# Restore from backup
echo "Restoring from backup: $BACKUP_FILE"
sudo etcdctl snapshot restore $BACKUP_FILE \
  --data-dir=/var/lib/etcd \
  --endpoints=https://127.0.0.1:2379

# Fix ownership
sudo chown -R etcd:etcd /var/lib/etcd

# Start kubelet
echo "Starting kubelet..."
sudo systemctl start kubelet

# Wait for API server
echo "Waiting for API server..."
sleep 30

# Verify restore
echo "Verifying restore..."
kubectl get nodes
kubectl get pods --all-namespaces

echo "Restore completed successfully!"
```

### Backup Verification

```bash
# Check backup integrity
etcdctl snapshot status /backup/etcd-snapshot-20231201-020000.db \
  --write-out=table

# List all keys in backup
etcdctl snapshot restore /backup/etcd-snapshot-20231201-020000.db \
  --data-dir=/tmp/etcd-restore-test

# Start temporary etcd instance for verification
etcd --data-dir=/tmp/etcd-restore-test --listen-client-urls=http://localhost:12379 &
ETCD_PID=$!

# Query restored data
etcdctl --endpoints=http://localhost:12379 get "" --prefix --keys-only

# Cleanup
kill $ETCD_PID
rm -rf /tmp/etcd-restore-test
```

## Networking Components

### 1. Container Network Interface (CNI)

**Popular CNI Plugins**:
- **Flannel**: Simple overlay network
- **Calico**: Network policy and security
- **Weave**: Mesh networking
- **Cilium**: eBPF-based networking

```bash
# Install Flannel CNI
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Install Calico CNI
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

### 2. CoreDNS

**Function**: Cluster DNS service for service discovery.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }
```

## Add-ons and Extensions

### 1. Metrics Server

```bash
# Install Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Verify installation
kubectl get pods -n kube-system | grep metrics-server
kubectl top nodes
kubectl top pods
```

### 2. Dashboard

```bash
# Install Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# Create admin user
kubectl create serviceaccount admin-user -n kubernetes-dashboard
kubectl create clusterrolebinding admin-user --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:admin-user

# Get access token
kubectl -n kubernetes-dashboard create token admin-user
```

### 3. Ingress Controllers

```bash
# Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# Install Traefik Ingress Controller
helm repo add traefik https://helm.traefik.io/traefik
helm install traefik traefik/traefik
```

## Monitoring and Troubleshooting

### Component Health Checks

```bash
# Check component status
kubectl get componentstatuses

# Check system pods
kubectl get pods -n kube-system

# Check node status
kubectl get nodes -o wide

# Describe problematic resources
kubectl describe node <node-name>
kubectl describe pod <pod-name> -n <namespace>

# Check logs
kubectl logs -n kube-system <pod-name>
journalctl -u kubelet
journalctl -u docker
```

### Performance Monitoring

```bash
# Resource usage
kubectl top nodes
kubectl top pods --all-namespaces

# Cluster info
kubectl cluster-info
kubectl cluster-info dump

# API server metrics
curl -k https://localhost:6443/metrics
```

---

**Next Steps**: Proceed to Task-k8s-03 for Kubernetes workload deployment, services, and application management.
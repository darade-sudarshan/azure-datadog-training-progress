# Task K8s-05: Kubernetes Networking and Volume Management

## Overview
This task covers comprehensive Kubernetes networking concepts and volume management, including CNI plugins, services, ingress, network policies, and various storage solutions with practical examples.

## Table of Contents
1. [Kubernetes Networking Fundamentals](#kubernetes-networking-fundamentals)
2. [Container Network Interface (CNI)](#container-network-interface-cni)
3. [Services and Service Discovery](#services-and-service-discovery)
4. [Ingress and Load Balancing](#ingress-and-load-balancing)
5. [Network Policies](#network-policies)
6. [Volume Management](#volume-management)
7. [Persistent Storage](#persistent-storage)
8. [Storage Classes](#storage-classes)
9. [Volume Snapshots](#volume-snapshots)
10. [Practical Examples](#practical-examples)

## Kubernetes Networking Fundamentals

### Networking Model
Kubernetes follows a flat networking model where:
- Every Pod gets its own IP address
- Pods can communicate with each other without NAT
- Nodes can communicate with all Pods without NAT
- Services provide stable endpoints for Pod groups

### Network Components
```yaml
# Pod Network Example
apiVersion: v1
kind: Pod
metadata:
  name: network-test-pod
  labels:
    app: network-test
spec:
  containers:
  - name: network-container
    image: busybox
    command: ['sleep', '3600']
    ports:
    - containerPort: 8080
      name: http
      protocol: TCP
  # Pod gets IP from cluster CIDR range
```

### Cluster Networking Architecture
```yaml
# Network configuration overview
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-network-info
data:
  cluster-cidr: "10.244.0.0/16"      # Pod IP range
  service-cidr: "10.96.0.0/12"       # Service IP range
  dns-domain: "cluster.local"        # DNS domain
  pod-subnet: "10.244.0.0/24"        # Per-node pod subnet
```

## Container Network Interface (CNI)

### CNI Plugin Types

#### Flannel CNI
```yaml
# Flannel DaemonSet configuration
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: kube-flannel-ds
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: flannel
  template:
    metadata:
      labels:
        app: flannel
    spec:
      hostNetwork: true
      containers:
      - name: kube-flannel
        image: quay.io/coreos/flannel:v0.20.2
        command:
        - /opt/bin/flanneld
        args:
        - --ip-masq
        - --kube-subnet-mgr
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        volumeMounts:
        - name: run
          mountPath: /run/flannel
        - name: flannel-cfg
          mountPath: /etc/kube-flannel/
      volumes:
      - name: run
        hostPath:
          path: /run/flannel
      - name: flannel-cfg
        configMap:
          name: kube-flannel-cfg
```

#### Calico CNI
```yaml
# Calico configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: calico-config
  namespace: kube-system
data:
  calico_backend: "bird"
  cluster_type: "k8s,bgp"
  cni_network_config: |
    {
      "name": "k8s-pod-network",
      "cniVersion": "0.3.1",
      "plugins": [
        {
          "type": "calico",
          "log_level": "info",
          "datastore_type": "kubernetes",
          "mtu": 1440,
          "ipam": {
            "type": "calico-ipam"
          },
          "policy": {
            "type": "k8s"
          },
          "kubernetes": {
            "kubeconfig": "/etc/cni/net.d/calico-kubeconfig"
          }
        }
      ]
    }
---
# Calico Node DaemonSet
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: calico-node
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: calico-node
  template:
    metadata:
      labels:
        k8s-app: calico-node
    spec:
      hostNetwork: true
      tolerations:
      - operator: Exists
      containers:
      - name: calico-node
        image: calico/node:v3.25.0
        env:
        - name: CALICO_IPV4POOL_CIDR
          value: "10.244.0.0/16"
        - name: CALICO_NETWORKING_BACKEND
          valueFrom:
            configMapKeyRef:
              name: calico-config
              key: calico_backend
```

### Network Troubleshooting Tools
```yaml
# Network debugging pod
apiVersion: v1
kind: Pod
metadata:
  name: network-debug
spec:
  containers:
  - name: debug
    image: nicolaka/netshoot
    command: ['sleep', '3600']
    securityContext:
      capabilities:
        add: ["NET_ADMIN"]
  restartPolicy: Never
```

## Services and Service Discovery

### Service Types and Examples

#### ClusterIP Service (Default)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  labels:
    app: backend
spec:
  type: ClusterIP
  selector:
    app: backend
    tier: api
  ports:
  - name: http
    port: 80
    targetPort: 8080
    protocol: TCP
  - name: metrics
    port: 9090
    targetPort: 9090
    protocol: TCP
```

#### NodePort Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-nodeport
  annotations:
    service.beta.kubernetes.io/external-traffic: OnlyLocal
spec:
  type: NodePort
  selector:
    app: frontend
  ports:
  - name: http
    port: 80
    targetPort: 3000
    nodePort: 30080
    protocol: TCP
  externalTrafficPolicy: Local  # Preserve source IP
```

#### LoadBalancer Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-loadbalancer
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
  - name: http
    port: 80
    targetPort: 8080
  - name: https
    port: 443
    targetPort: 8443
  loadBalancerSourceRanges:
  - 10.0.0.0/8
  - 172.16.0.0/12
```

#### Headless Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: database-headless
spec:
  clusterIP: None  # Makes it headless
  selector:
    app: database
  ports:
  - name: mysql
    port: 3306
    targetPort: 3306
---
# StatefulSet using headless service
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql-cluster
spec:
  serviceName: database-headless
  replicas: 3
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
```

#### ExternalName Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-database
spec:
  type: ExternalName
  externalName: db.example.com
  ports:
  - name: mysql
    port: 3306
    targetPort: 3306
```

### Service Discovery
```yaml
# DNS-based service discovery example
apiVersion: v1
kind: Pod
metadata:
  name: service-discovery-test
spec:
  containers:
  - name: test
    image: busybox
    command: ['sleep', '3600']
    env:
    # Service discovery via environment variables
    - name: BACKEND_SERVICE_HOST
      value: backend-service.default.svc.cluster.local
    - name: BACKEND_SERVICE_PORT
      value: "80"
```

### Endpoints and EndpointSlices
```yaml
# Manual Endpoints (for external services)
apiVersion: v1
kind: Endpoints
metadata:
  name: external-api
subsets:
- addresses:
  - ip: 192.168.1.100
  - ip: 192.168.1.101
  ports:
  - name: http
    port: 8080
    protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
  name: external-api
spec:
  ports:
  - name: http
    port: 80
    targetPort: 8080
```

## Ingress and Load Balancing

### Ingress Controllers

#### NGINX Ingress Controller
```yaml
# NGINX Ingress Controller deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-ingress-controller
  namespace: ingress-nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-ingress
  template:
    metadata:
      labels:
        app: nginx-ingress
    spec:
      containers:
      - name: nginx-ingress-controller
        image: k8s.gcr.io/ingress-nginx/controller:v1.8.1
        args:
        - /nginx-ingress-controller
        - --configmap=$(POD_NAMESPACE)/nginx-configuration
        - --tcp-services-configmap=$(POD_NAMESPACE)/tcp-services
        - --udp-services-configmap=$(POD_NAMESPACE)/udp-services
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        ports:
        - name: http
          containerPort: 80
        - name: https
          containerPort: 443
```

### Ingress Resources

#### Basic Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

#### Multi-Host Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: multi-host-ingress
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
spec:
  ingressClassName: nginx
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /v1
        pathType: Prefix
        backend:
          service:
            name: api-v1-service
            port:
              number: 80
      - path: /v2
        pathType: Prefix
        backend:
          service:
            name: api-v2-service
            port:
              number: 80
  - host: admin.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: admin-service
            port:
              number: 80
```

#### TLS Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - secure.example.com
    - api.example.com
    secretName: example-tls
  rules:
  - host: secure.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: secure-service
            port:
              number: 443
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
```

#### Advanced Ingress with Annotations
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: advanced-ingress
  annotations:
    # Rate limiting
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
    
    # Authentication
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    
    # CORS
    nginx.ingress.kubernetes.io/enable-cors: "true"
    nginx.ingress.kubernetes.io/cors-allow-methods: "GET, POST, PUT, DELETE"
    
    # Custom headers
    nginx.ingress.kubernetes.io/configuration-snippet: |
      add_header X-Frame-Options SAMEORIGIN;
      add_header X-Content-Type-Options nosniff;
    
    # Load balancing
    nginx.ingress.kubernetes.io/upstream-hash-by: "$request_uri"
    
    # Timeouts
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "60"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "60"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "60"
spec:
  ingressClassName: nginx
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-service
            port:
              number: 80
```

## Network Policies

### Basic Network Policy
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: production
spec:
  podSelector: {}  # Applies to all pods in namespace
  policyTypes:
  - Ingress
  - Egress
  # No ingress/egress rules = deny all
```

### Allow Specific Traffic
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: web-netpol
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    - namespaceSelector:
        matchLabels:
          name: staging
    - ipBlock:
        cidr: 10.0.0.0/8
        except:
        - 10.0.1.0/24
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 3306
  - to: []  # Allow all egress to internet
    ports:
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 80
```

### Database Access Policy
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-policy
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: backend
    - podSelector:
        matchLabels:
          role: api
    ports:
    - protocol: TCP
      port: 3306
    - protocol: TCP
      port: 5432
```

### Namespace Isolation Policy
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: namespace-isolation
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: production
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: production
  - to: []  # Allow egress to internet
    ports:
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 80
    - protocol: UDP
      port: 53
```

## Volume Management

### Volume Types

#### EmptyDir Volume
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: emptydir-example
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: cache-volume
      mountPath: /cache
    - name: tmp-volume
      mountPath: /tmp
  - name: sidecar
    image: busybox
    command: ['sleep', '3600']
    volumeMounts:
    - name: cache-volume
      mountPath: /shared-cache
  volumes:
  - name: cache-volume
    emptyDir:
      sizeLimit: 1Gi
      medium: Memory  # Use tmpfs (RAM)
  - name: tmp-volume
    emptyDir: {}
```

#### HostPath Volume
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hostpath-example
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: host-logs
      mountPath: /var/log/nginx
    - name: host-config
      mountPath: /etc/nginx/conf.d
      readOnly: true
  volumes:
  - name: host-logs
    hostPath:
      path: /var/log/nginx
      type: DirectoryOrCreate
  - name: host-config
    hostPath:
      path: /etc/nginx/conf.d
      type: Directory
```

#### ConfigMap Volume
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  config.yaml: |
    server:
      port: 8080
      host: 0.0.0.0
    database:
      host: db.example.com
      port: 5432
  nginx.conf: |
    server {
        listen 80;
        location / {
            proxy_pass http://backend;
        }
    }
---
apiVersion: v1
kind: Pod
metadata:
  name: configmap-volume-example
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
    - name: nginx-config
      mountPath: /etc/nginx/conf.d
  volumes:
  - name: config-volume
    configMap:
      name: app-config
      items:
      - key: config.yaml
        path: app-config.yaml
        mode: 0644
  - name: nginx-config
    configMap:
      name: app-config
      items:
      - key: nginx.conf
        path: default.conf
```

#### Secret Volume
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  username: YWRtaW4=
  password: cGFzc3dvcmQ=
  api-key: bXlfc2VjcmV0X2tleQ==
---
apiVersion: v1
kind: Pod
metadata:
  name: secret-volume-example
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: app-secret
      defaultMode: 0400
      items:
      - key: username
        path: db-username
      - key: password
        path: db-password
```

## Persistent Storage

### PersistentVolume (PV)
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
  labels:
    type: local
    app: mysql
spec:
  capacity:
    storage: 20Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /mnt/mysql-data
---
# NFS PersistentVolume
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
  capacity:
    storage: 100Gi
  accessModes:
  - ReadWriteMany
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: nfs
  nfs:
    server: nfs-server.example.com
    path: /shared/data
```

### PersistentVolumeClaim (PVC)
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: manual
  selector:
    matchLabels:
      app: mysql
---
# Dynamic PVC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi
  storageClassName: fast-ssd
```

### Using PVC in Pods
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mysql-pod
spec:
  containers:
  - name: mysql
    image: mysql:8.0
    env:
    - name: MYSQL_ROOT_PASSWORD
      value: "password"
    ports:
    - containerPort: 3306
    volumeMounts:
    - name: mysql-storage
      mountPath: /var/lib/mysql
  volumes:
  - name: mysql-storage
    persistentVolumeClaim:
      claimName: mysql-pvc
```

### StatefulSet with PVC Templates
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
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
        - name: mysql-config
          mountPath: /etc/mysql/conf.d
      volumes:
      - name: mysql-config
        configMap:
          name: mysql-config
  volumeClaimTemplates:
  - metadata:
      name: mysql-storage
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: fast-ssd
      resources:
        requests:
          storage: 20Gi
```

## Storage Classes

### AWS EBS StorageClass
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: aws-ebs-gp3
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
  encrypted: "true"
  kmsKeyId: "arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"
allowVolumeExpansion: true
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
mountOptions:
- debug
```

### Azure Disk StorageClass
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azure-disk-premium
provisioner: disk.csi.azure.com
parameters:
  skuName: Premium_LRS
  location: eastus
  resourceGroup: myResourceGroup
allowVolumeExpansion: true
reclaimPolicy: Delete
volumeBindingMode: Immediate
```

### GCP Persistent Disk StorageClass
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gcp-ssd
provisioner: pd.csi.storage.gke.io
parameters:
  type: pd-ssd
  zones: us-central1-a,us-central1-b
  replication-type: regional-pd
allowVolumeExpansion: true
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

### Local StorageClass
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Delete
---
# Local PersistentVolume
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv
spec:
  capacity:
    storage: 100Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage
  local:
    path: /mnt/disks/ssd1
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - worker-node-1
```

## Volume Snapshots

### VolumeSnapshotClass
```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: csi-snapclass
driver: ebs.csi.aws.com
deletionPolicy: Delete
parameters:
  tagSpecification_1: "Name=*"
  tagSpecification_2: "Environment=production"
```

### VolumeSnapshot
```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: mysql-snapshot
spec:
  volumeSnapshotClassName: csi-snapclass
  source:
    persistentVolumeClaimName: mysql-pvc
---
# Restore from snapshot
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc-restored
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 20Gi
  dataSource:
    name: mysql-snapshot
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
```

## Practical Examples

### Complete Web Application with Networking and Storage
```yaml
# Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: webapp
---
# StorageClass
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: webapp-storage
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  iops: "3000"
allowVolumeExpansion: true
reclaimPolicy: Delete
---
# Database PVC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
  namespace: webapp
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: webapp-storage
  resources:
    requests:
      storage: 20Gi
---
# Database StatefulSet
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  namespace: webapp
spec:
  serviceName: mysql
  replicas: 1
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
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: password
        - name: MYSQL_DATABASE
          value: webapp
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-storage
        persistentVolumeClaim:
          claimName: mysql-pvc
---
# Database Service
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: webapp
spec:
  clusterIP: None
  selector:
    app: mysql
  ports:
  - port: 3306
---
# Backend Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: webapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: backend:v1.0
        ports:
        - containerPort: 8080
        env:
        - name: DB_HOST
          value: mysql.webapp.svc.cluster.local
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: password
        volumeMounts:
        - name: app-config
          mountPath: /etc/config
        - name: logs
          mountPath: /var/log
      volumes:
      - name: app-config
        configMap:
          name: backend-config
      - name: logs
        emptyDir: {}
---
# Backend Service
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: webapp
spec:
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 8080
---
# Frontend Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: webapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: frontend:v1.0
        ports:
        - containerPort: 3000
        env:
        - name: BACKEND_URL
          value: http://backend.webapp.svc.cluster.local
---
# Frontend Service
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: webapp
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 3000
---
# Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: webapp-ingress
  namespace: webapp
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - webapp.example.com
    secretName: webapp-tls
  rules:
  - host: webapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend
            port:
              number: 80
---
# Network Policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: webapp-netpol
  namespace: webapp
spec:
  podSelector:
    matchLabels:
      app: mysql
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 3306
```

### Network Troubleshooting Commands
```bash
# Test pod connectivity
kubectl exec -it network-debug -- ping 10.244.1.5

# Check DNS resolution
kubectl exec -it network-debug -- nslookup kubernetes.default.svc.cluster.local

# Test service connectivity
kubectl exec -it network-debug -- curl http://backend-service.default.svc.cluster.local

# Check network policies
kubectl get networkpolicies
kubectl describe networkpolicy webapp-netpol

# Inspect endpoints
kubectl get endpoints
kubectl describe endpoints backend-service

# Check ingress status
kubectl get ingress
kubectl describe ingress webapp-ingress

# Volume troubleshooting
kubectl get pv,pvc
kubectl describe pvc mysql-pvc
kubectl get storageclass

# Check volume snapshots
kubectl get volumesnapshots
kubectl describe volumesnapshot mysql-snapshot
```

---

**Next Steps**: Proceed to Task-k8s-06 for advanced Kubernetes security, RBAC, and monitoring concepts.
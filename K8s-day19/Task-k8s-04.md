# Task K8s-04: Kubernetes Workload Concepts and YAML Examples

## Overview
This task covers all Kubernetes workload concepts including Pods, ReplicaSets, Deployments, StatefulSets, DaemonSets, Jobs, and CronJobs with comprehensive YAML examples and practical use cases.

## Table of Contents
1. [Pods](#pods)
2. [ReplicaSets](#replicasets)
3. [Deployments](#deployments)
4. [StatefulSets](#statefulsets)
5. [DaemonSets](#daemonsets)
6. [Jobs](#jobs)
7. [CronJobs](#cronjobs)
8. [Services](#services)
9. [Ingress](#ingress)
10. [ConfigMaps and Secrets](#configmaps-and-secrets)

## Pods

### Concept
Pods are the smallest deployable units in Kubernetes. A Pod represents a single instance of a running process and can contain one or more containers that share storage and network.

**Key Characteristics:**
- **Atomic Unit**: Pods are created, scheduled, and destroyed as a single unit
- **Shared Resources**: Containers in a pod share the same network (IP address) and storage volumes
- **Co-location**: All containers in a pod are always scheduled on the same node
- **Ephemeral**: Pods are mortal - they can be created, destroyed, and recreated
- **Single Responsibility**: Each pod should represent a single application or tightly coupled components

**Use Cases:**
- Single container applications
- Sidecar patterns (logging, monitoring, proxies)
- Helper containers that support the main application
- Init containers for setup tasks

### Basic Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: simple-pod
  labels:
    app: web
    version: v1
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
```

### Multi-Container Pod (Sidecar Pattern)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-pod
  labels:
    app: web-with-logging
spec:
  containers:
  - name: web-server
    image: nginx:1.21
    ports:
    - containerPort: 80
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/nginx
  - name: log-agent
    image: fluentd:v1.14
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/nginx
      readOnly: true
  volumes:
  - name: shared-logs
    emptyDir: {}
```

### Pod with Init Container
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-container-pod
spec:
  initContainers:
  - name: init-myservice
    image: busybox:1.28
    command: ['sh', '-c', 'until nslookup myservice; do echo waiting for myservice; sleep 2; done;']
  - name: init-mydb
    image: busybox:1.28
    command: ['sh', '-c', 'until nslookup mydb; do echo waiting for mydb; sleep 2; done;']
  containers:
  - name: myapp-container
    image: busybox:1.28
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
```

### Pod with Resource Limits and Health Checks
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-pod
spec:
  containers:
  - name: app
    image: nginx:1.21
    ports:
    - containerPort: 80
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 30
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
```

### Pod with Security Context
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-context-pod
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  containers:
  - name: sec-ctx-demo
    image: busybox
    command: [ "sh", "-c", "sleep 1h" ]
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      capabilities:
        drop:
        - ALL
```

## ReplicaSets

### Concept
ReplicaSets ensure that a specified number of pod replicas are running at any given time. They are typically managed by Deployments.

**Key Features:**
- **Desired State**: Maintains the desired number of pod replicas
- **Self-Healing**: Automatically replaces failed or deleted pods
- **Label Selectors**: Uses labels to identify which pods it manages
- **Scaling**: Can scale up or down the number of replicas
- **Pod Template**: Defines the specification for creating new pods

**How it Works:**
1. Continuously monitors the number of running pods matching its selector
2. Creates new pods if the count is below the desired replica count
3. Deletes excess pods if the count exceeds the desired replica count
4. Ensures pods are distributed across available nodes

**Note**: ReplicaSets are rarely created directly; they're usually managed by Deployments.

### Basic ReplicaSet
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-replicaset
  labels:
    app: nginx
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

### ReplicaSet with Advanced Selector
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: advanced-replicaset
spec:
  replicas: 3
  selector:
    matchLabels:
      tier: frontend
    matchExpressions:
    - key: environment
      operator: In
      values: [production, staging]
  template:
    metadata:
      labels:
        tier: frontend
        environment: production
    spec:
      containers:
      - name: web
        image: nginx:1.21
        ports:
        - containerPort: 80
```

## Deployments

### Concept
Deployments provide declarative updates for Pods and ReplicaSets. They manage the rollout of new versions and can rollback to previous versions.

**Key Features:**
- **Declarative Updates**: Describe the desired state, and Deployment controller changes the actual state
- **Rolling Updates**: Gradually replace old pods with new ones to ensure zero downtime
- **Rollback Capability**: Can rollback to previous versions if issues occur
- **Scaling**: Easy horizontal scaling of applications
- **Revision History**: Maintains history of deployments for rollback purposes

**Deployment Strategies:**
- **Rolling Update** (Default): Gradually replaces old pods with new ones
  - `maxUnavailable`: Maximum number of pods that can be unavailable during update
  - `maxSurge`: Maximum number of pods that can be created above desired replica count
- **Recreate**: Terminates all existing pods before creating new ones (causes downtime)

**Use Cases:**
- Stateless applications
- Web servers and APIs
- Microservices
- Any application requiring rolling updates

### Basic Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
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

### Deployment with Rolling Update Strategy
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rolling-deployment
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginx:1.21
        ports:
        - containerPort: 80
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 20
```

### Deployment with Recreate Strategy
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: recreate-deployment
spec:
  replicas: 3
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_PASSWORD
          value: "password"
        ports:
        - containerPort: 5432
```

### Blue-Green Deployment Example
```yaml
# Blue Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-blue
  labels:
    app: myapp
    version: blue
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: blue
  template:
    metadata:
      labels:
        app: myapp
        version: blue
    spec:
      containers:
      - name: app
        image: myapp:v1.0
        ports:
        - containerPort: 8080
---
# Green Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-green
  labels:
    app: myapp
    version: green
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: green
  template:
    metadata:
      labels:
        app: myapp
        version: green
    spec:
      containers:
      - name: app
        image: myapp:v2.0
        ports:
        - containerPort: 8080
```

## StatefulSets

### Concept
StatefulSets manage stateful applications, providing stable network identities, persistent storage, and ordered deployment/scaling.

**Key Features:**
- **Stable Network Identity**: Each pod gets a persistent hostname (pod-0, pod-1, etc.)
- **Ordered Deployment**: Pods are created, updated, and deleted in order
- **Persistent Storage**: Each pod can have its own persistent volume
- **Stable Storage**: Storage persists across pod rescheduling
- **Ordered Scaling**: Scaling operations happen in order

**Characteristics:**
- **Predictable Names**: Pods are named with ordinal indices (web-0, web-1, web-2)
- **Headless Service**: Usually paired with a headless service for direct pod access
- **Volume Claims**: Uses VolumeClaimTemplates for persistent storage
- **Graceful Deployment**: Waits for each pod to be ready before creating the next

**Use Cases:**
- Databases (MySQL, PostgreSQL, MongoDB)
- Distributed systems (Kafka, Elasticsearch, Cassandra)
- Applications requiring stable network identities
- Applications needing persistent storage
- Master-slave configurations

### Basic StatefulSet
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web-statefulset
spec:
  serviceName: nginx
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
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
```

### MySQL StatefulSet with Persistent Storage
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
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: password
        - name: MYSQL_DATABASE
          value: "myapp"
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
      resources:
        requests:
          storage: 10Gi
```

### Headless Service for StatefulSet
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql
  labels:
    app: mysql
spec:
  ports:
  - port: 3306
    name: mysql
  clusterIP: None
  selector:
    app: mysql
```

### Cassandra StatefulSet Cluster
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: cassandra
  labels:
    app: cassandra
spec:
  serviceName: cassandra
  replicas: 3
  selector:
    matchLabels:
      app: cassandra
  template:
    metadata:
      labels:
        app: cassandra
    spec:
      terminationGracePeriodSeconds: 1800
      containers:
      - name: cassandra
        image: cassandra:3.11
        ports:
        - containerPort: 7000
          name: intra-node
        - containerPort: 7001
          name: tls-intra-node
        - containerPort: 7199
          name: jmx
        - containerPort: 9042
          name: cql
        resources:
          limits:
            cpu: "500m"
            memory: 1Gi
          requests:
            cpu: "500m"
            memory: 1Gi
        env:
        - name: MAX_HEAP_SIZE
          value: 512M
        - name: HEAP_NEWSIZE
          value: 100M
        - name: CASSANDRA_SEEDS
          value: "cassandra-0.cassandra.default.svc.cluster.local"
        - name: CASSANDRA_CLUSTER_NAME
          value: "K8Demo"
        - name: CASSANDRA_DC
          value: "DC1-K8Demo"
        - name: CASSANDRA_RACK
          value: "Rack1-K8Demo"
        volumeMounts:
        - name: cassandra-data
          mountPath: /cassandra_data
  volumeClaimTemplates:
  - metadata:
      name: cassandra-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
```

## DaemonSets

### Concept
DaemonSets ensure that all (or some) nodes run a copy of a Pod. Typically used for system daemons, monitoring agents, and log collectors.

**Key Features:**
- **Node Coverage**: Ensures one pod per node (or selected nodes)
- **Automatic Scheduling**: Automatically schedules pods on new nodes
- **Node Removal**: Automatically removes pods when nodes are removed
- **System-Level Services**: Perfect for cluster-wide services
- **Tolerations**: Can run on nodes with taints (including master nodes)

**Characteristics:**
- **No Replica Count**: Number of pods equals number of eligible nodes
- **Node Selector**: Can target specific nodes using nodeSelector or affinity
- **Host Resources**: Often needs access to host resources (network, filesystem)
- **Privileged Access**: May require elevated privileges for system operations

**Use Cases:**
- **Log Collection**: Fluentd, Filebeat for collecting logs from all nodes
- **Monitoring**: Node exporters, monitoring agents
- **Networking**: CNI plugins, kube-proxy
- **Storage**: Storage daemons, CSI drivers
- **Security**: Security agents, vulnerability scanners
- **System Utilities**: Cleanup jobs, maintenance tasks

### Basic DaemonSet
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd-daemonset
  labels:
    app: fluentd
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
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
```

### Node Exporter DaemonSet
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  labels:
    app: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      hostNetwork: true
      hostPID: true
      containers:
      - name: node-exporter
        image: prom/node-exporter:latest
        ports:
        - containerPort: 9100
          hostPort: 9100
        args:
        - --path.procfs=/host/proc
        - --path.sysfs=/host/sys
        - --collector.filesystem.ignored-mount-points
        - ^/(sys|proc|dev|host|etc|rootfs/var/lib/docker/containers|rootfs/var/lib/docker/overlay2|rootfs/run/docker/netns|rootfs/var/lib/docker/aufs)($$|/)
        volumeMounts:
        - name: proc
          mountPath: /host/proc
          readOnly: true
        - name: sys
          mountPath: /host/sys
          readOnly: true
        - name: root
          mountPath: /rootfs
          readOnly: true
      volumes:
      - name: proc
        hostPath:
          path: /proc
      - name: sys
        hostPath:
          path: /sys
      - name: root
        hostPath:
          path: /
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
```

### DaemonSet with Node Selector
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ssd-monitor
spec:
  selector:
    matchLabels:
      app: ssd-monitor
  template:
    metadata:
      labels:
        app: ssd-monitor
    spec:
      nodeSelector:
        disktype: ssd
      containers:
      - name: ssd-monitor
        image: monitoring-agent:latest
        resources:
          limits:
            memory: 100Mi
          requests:
            cpu: 50m
            memory: 100Mi
```

## Jobs

### Concept
Jobs run Pods to completion. They are used for batch processing, one-time tasks, and parallel processing.

**Key Features:**
- **Run to Completion**: Ensures pods complete successfully
- **Retry Logic**: Automatically retries failed pods (up to backoffLimit)
- **Parallel Execution**: Can run multiple pods in parallel
- **Completion Tracking**: Tracks successful completions
- **Cleanup**: Can automatically clean up completed pods

**Job Types:**
- **Single Job**: Runs one pod to completion
- **Parallel Jobs with Fixed Completion Count**: Runs N pods to completion
- **Parallel Jobs with Work Queue**: Multiple pods process items from a shared queue

**Configuration Options:**
- **completions**: Number of successful pod completions required
- **parallelism**: Maximum number of pods running simultaneously
- **backoffLimit**: Number of retries before marking job as failed
- **activeDeadlineSeconds**: Maximum time job can run

**Use Cases:**
- **Batch Processing**: Data processing, ETL jobs
- **Database Operations**: Migrations, backups, maintenance
- **CI/CD Tasks**: Build jobs, testing, deployment tasks
- **One-time Tasks**: Setup scripts, data imports
- **Parallel Computing**: Scientific computing, image processing

### Basic Job
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi-calculation
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
```

### Parallel Job
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: parallel-job
spec:
  parallelism: 3
  completions: 6
  template:
    spec:
      containers:
      - name: worker
        image: busybox
        command: ["sh", "-c", "echo Processing item $RANDOM && sleep 30"]
      restartPolicy: Never
  backoffLimit: 3
```

### Job with Work Queue
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: work-queue-job
spec:
  parallelism: 2
  template:
    spec:
      containers:
      - name: worker
        image: worker:latest
        env:
        - name: QUEUE_URL
          value: "redis://redis-service:6379"
      restartPolicy: Never
```

### Database Migration Job
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migration
spec:
  template:
    spec:
      containers:
      - name: migration
        image: migrate/migrate
        command: ["migrate"]
        args: ["-path", "/migrations", "-database", "postgres://user:pass@db:5432/mydb?sslmode=disable", "up"]
        volumeMounts:
        - name: migrations
          mountPath: /migrations
      volumes:
      - name: migrations
        configMap:
          name: db-migrations
      restartPolicy: Never
  backoffLimit: 3
```

## CronJobs

### Concept
CronJobs create Jobs on a time-based schedule using cron format.

**Key Features:**
- **Scheduled Execution**: Runs jobs at specified times using cron syntax
- **Job Management**: Creates and manages Job objects automatically
- **History Management**: Maintains history of successful and failed jobs
- **Concurrency Control**: Can prevent overlapping job executions
- **Timezone Support**: Supports timezone-aware scheduling

**Cron Schedule Format:**
```
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of the month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday)
# │ │ │ │ │
# * * * * *
```

**Common Schedules:**
- `"0 0 * * *"` - Daily at midnight
- `"0 2 * * 0"` - Weekly on Sunday at 2 AM
- `"*/15 * * * *"` - Every 15 minutes
- `"0 9-17 * * 1-5"` - Every hour from 9 AM to 5 PM, Monday to Friday

**Configuration Options:**
- **schedule**: Cron expression for timing
- **concurrencyPolicy**: How to handle overlapping jobs (Allow, Forbid, Replace)
- **successfulJobsHistoryLimit**: Number of successful jobs to keep
- **failedJobsHistoryLimit**: Number of failed jobs to keep
- **startingDeadlineSeconds**: Deadline for starting missed jobs

**Use Cases:**
- **Backups**: Database backups, file system backups
- **Maintenance**: Log cleanup, cache clearing, system updates
- **Monitoring**: Health checks, report generation
- **Data Processing**: ETL jobs, data synchronization
- **Notifications**: Sending reports, alerts, reminders

### Basic CronJob
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello-cronjob
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            command: ["sh", "-c", "date; echo Hello from the Kubernetes cluster"]
          restartPolicy: OnFailure
```

### Database Backup CronJob
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: database-backup
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: postgres:13
            command: ["sh", "-c"]
            args:
            - |
              pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME > /backup/backup-$(date +%Y%m%d-%H%M%S).sql
            env:
            - name: DB_HOST
              value: "postgres-service"
            - name: DB_USER
              value: "postgres"
            - name: DB_NAME
              value: "myapp"
            - name: PGPASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: password
            volumeMounts:
            - name: backup-storage
              mountPath: /backup
          volumes:
          - name: backup-storage
            persistentVolumeClaim:
              claimName: backup-pvc
          restartPolicy: OnFailure
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
```

### Log Cleanup CronJob
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: log-cleanup
spec:
  schedule: "0 0 * * 0"  # Weekly on Sunday
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: cleanup
            image: busybox
            command: ["sh", "-c"]
            args:
            - |
              find /var/log -name "*.log" -mtime +7 -delete
              echo "Log cleanup completed at $(date)"
            volumeMounts:
            - name: log-volume
              mountPath: /var/log
          volumes:
          - name: log-volume
            hostPath:
              path: /var/log
          restartPolicy: OnFailure
  concurrencyPolicy: Forbid
```

## Services

### Concept
Services provide stable network endpoints for accessing pods. They abstract away the dynamic nature of pods and provide load balancing.

**Key Features:**
- **Service Discovery**: Provides stable DNS names and IP addresses
- **Load Balancing**: Distributes traffic across multiple pod replicas
- **Abstraction**: Decouples clients from specific pod instances
- **Health Checking**: Only routes traffic to healthy pods
- **Multiple Protocols**: Supports TCP, UDP, and SCTP

**Service Types:**
- **ClusterIP** (Default): Internal cluster communication only
- **NodePort**: Exposes service on each node's IP at a static port
- **LoadBalancer**: Exposes service externally using cloud provider's load balancer
- **ExternalName**: Maps service to external DNS name

**How Services Work:**
1. Service controller watches for pods matching the selector
2. Creates endpoints for healthy pods
3. kube-proxy configures network rules (iptables/IPVS) on each node
4. Traffic is distributed among available endpoints

### ClusterIP Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  type: ClusterIP
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
```

### NodePort Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-nodeport
spec:
  type: NodePort
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 3000
    nodePort: 30080
```

### LoadBalancer Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-loadbalancer
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: nlb
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
  loadBalancerSourceRanges:
  - 10.0.0.0/8
```

### ExternalName Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-db
spec:
  type: ExternalName
  externalName: db.example.com
  ports:
  - port: 3306
```

## Ingress

### Concept
Ingress manages external access to services in a cluster, typically HTTP/HTTPS. It provides load balancing, SSL termination, and name-based virtual hosting.

**Key Features:**
- **HTTP/HTTPS Routing**: Routes traffic based on hostnames and paths
- **SSL Termination**: Handles TLS certificates and encryption
- **Load Balancing**: Distributes traffic across backend services
- **Virtual Hosting**: Multiple domains on single IP address
- **Path-based Routing**: Route different paths to different services

**Components:**
- **Ingress Resource**: Defines routing rules
- **Ingress Controller**: Implements the routing (nginx, traefik, etc.)
- **Backend Services**: Target services for traffic

**Ingress vs Service:**
- **Service**: Layer 4 (TCP/UDP) load balancing
- **Ingress**: Layer 7 (HTTP/HTTPS) routing with advanced features

**Use Cases:**
- **Web Applications**: Exposing web apps to the internet
- **API Gateways**: Routing API requests to microservices
- **Multi-tenant Applications**: Hosting multiple applications
- **SSL Termination**: Centralizing certificate management

### Basic Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
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

### Multi-Path Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: multi-path-ingress
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /api/v1
        pathType: Prefix
        backend:
          service:
            name: api-v1-service
            port:
              number: 80
      - path: /api/v2
        pathType: Prefix
        backend:
          service:
            name: api-v2-service
            port:
              number: 80
```

### TLS Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
spec:
  tls:
  - hosts:
    - secure.example.com
    secretName: tls-secret
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
```

## ConfigMaps and Secrets

### Concept
ConfigMaps and Secrets manage configuration data and sensitive information separately from application code.

**ConfigMaps:**
- **Purpose**: Store non-sensitive configuration data
- **Data Types**: Key-value pairs, configuration files, environment variables
- **Usage**: Mounted as volumes or exposed as environment variables
- **Mutability**: Can be updated (pods need restart to see changes)

**Secrets:**
- **Purpose**: Store sensitive data (passwords, tokens, keys)
- **Encoding**: Base64 encoded (not encrypted by default)
- **Types**: Opaque, TLS, Docker registry, Service account tokens
- **Security**: Should be encrypted at rest and in transit

**Benefits:**
- **Separation of Concerns**: Configuration separate from application code
- **Reusability**: Same config can be used by multiple applications
- **Environment Management**: Different configs for dev/staging/prod
- **Security**: Sensitive data handled separately

**Best Practices:**
- Use external secret management systems for production
- Enable encryption at rest for etcd
- Limit access using RBAC
- Rotate secrets regularly
- Use immutable ConfigMaps for better caching

### ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database.host: "mysql.example.com"
  database.port: "3306"
  app.properties: |
    debug=true
    log.level=INFO
    max.connections=100
  nginx.conf: |
    server {
        listen 80;
        server_name localhost;
        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
    }
```

### Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  username: YWRtaW4=        # base64 encoded 'admin'
  password: cGFzc3dvcmQ=    # base64 encoded 'password'
  api-key: bXlfc2VjcmV0X2tleQ==  # base64 encoded 'my_secret_key'
```

### TLS Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
type: kubernetes.io/tls
data:
  tls.crt: LS0tLS1CRUdJTi...  # base64 encoded certificate
  tls.key: LS0tLS1CRUdJTi...  # base64 encoded private key
```

## Complete Application Example

### Three-Tier Application
```yaml
# Database StatefulSet
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
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
          value: "webapp"
        ports:
        - containerPort: 3306
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
---
# Database Service
apiVersion: v1
kind: Service
metadata:
  name: mysql
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
          value: "mysql"
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: password
---
# Backend Service
apiVersion: v1
kind: Service
metadata:
  name: backend
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
          value: "http://backend"
---
# Frontend Service
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  type: LoadBalancer
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 3000
---
# MySQL Secret
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
type: Opaque
data:
  password: cGFzc3dvcmQ=  # base64 encoded 'password'
```

## Management Commands

```bash
# Pod operations
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- /bin/bash

# Deployment operations
kubectl get deployments
kubectl scale deployment <deployment-name> --replicas=5
kubectl rollout status deployment <deployment-name>
kubectl rollout history deployment <deployment-name>
kubectl rollout undo deployment <deployment-name>

# StatefulSet operations
kubectl get statefulsets
kubectl scale statefulset <statefulset-name> --replicas=3
kubectl delete pod <statefulset-pod-name>  # Recreates with same identity

# Service operations
kubectl get services
kubectl describe service <service-name>
kubectl port-forward service/<service-name> 8080:80

# Job operations
kubectl get jobs
kubectl describe job <job-name>
kubectl logs job/<job-name>

# CronJob operations
kubectl get cronjobs
kubectl create job --from=cronjob/<cronjob-name> <job-name>
```

---

**Next Steps**: Proceed to Task-k8s-05 for advanced Kubernetes networking, security, and monitoring concepts.
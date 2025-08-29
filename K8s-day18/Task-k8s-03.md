# Task K8s-03: Kubernetes YAML Syntax and Core Concepts

## Overview
This task covers Kubernetes YAML file syntax, core concepts, and practical examples for creating and managing Kubernetes resources with comprehensive YAML data structures.

## Table of Contents
1. [YAML Basics](#yaml-basics)
2. [Kubernetes Resource Structure](#kubernetes-resource-structure)
3. [YAML Best Practices](#yaml-best-practices)
4. [Pods](#pods)
5. [Services](#services)
6. [Deployments](#deployments)
7. [ConfigMaps and Secrets](#configmaps-and-secrets)
8. [Volumes and Storage](#volumes-and-storage)
9. [Namespaces](#namespaces)
10. [Resource Management](#resource-management)
11. [Labels and Selectors](#labels-and-selectors)

## YAML Basics

### YAML Syntax Rules and Data Types

#### Scalars (Simple Values)
```yaml
# Comments start with #

# Strings (quotes optional for simple strings)
string_value: hello world
quoted_string: "hello world"
single_quoted: 'hello world'
special_chars: "Line 1\nLine 2\tTabbed"

# Numbers
integer: 42
float: 3.14159
scientific: 1.23e+3
octal: 0o755
hexadecimal: 0xFF

# Booleans
boolean_true: true
boolean_false: false
yes_value: yes
no_value: no
on_value: on
off_value: off

# Null values
null_value: null
empty_value: ~
null_explicit: !!null

# Dates and timestamps
date: 2023-12-01
datetime: 2023-12-01T10:30:00Z
timestamp: !!timestamp 2023-12-01T10:30:00Z
```

#### Lists (Arrays/Sequences)
```yaml
# Block style lists
fruits:
  - apple
  - banana
  - orange
  - "grape with spaces"

# Flow style (inline) lists
colors: [red, green, blue, yellow]
numbers: [1, 2, 3, 4, 5]

# Mixed data types in lists
mixed_list:
  - string_item
  - 42
  - true
  - null
  - [nested, list]
  - nested_object:
      key: value

# Multi-line list items
commands:
  - |
    echo "First command"
    echo "Second line"
  - >
    This is a long command
    that spans multiple lines
    but will be folded

# Empty list
empty_list: []
also_empty: []
```

#### Maps/Dictionaries (Key-Value Pairs)
```yaml
# Block style maps
person:
  name: John Doe
  age: 30
  city: New York
  active: true

# Flow style (inline) maps
coordinates: {x: 10, y: 20, z: 30}
config: {debug: true, timeout: 30}

# Nested maps
address:
  street:
    number: 123
    name: Main Street
  city: Springfield
  country: USA
  coordinates:
    latitude: 40.7128
    longitude: -74.0060

# Complex keys (quoted)
"key with spaces": value1
"key:with:colons": value2
"123numeric_key": value3

# Empty map
empty_map: {}
also_empty_map: {}
```

#### Multi-line Strings
```yaml
# Literal style (preserves line breaks and trailing spaces)
literal_string: |
  This is line 1
  This is line 2
    This line is indented
  Final line

# Folded style (folds line breaks into spaces)
folded_string: >
  This is a very long line
  that will be folded into
  a single line with spaces
  between the words.

# Literal with strip final newlines
literal_strip: |-
  Line 1
  Line 2
  No final newline

# Literal with keep final newlines
literal_keep: |+
  Line 1
  Line 2
  Keeps final newlines

# Folded with strip
folded_strip: >-
  This text will be folded
  and final newline stripped

# Folded with keep
folded_keep: >+
  This text will be folded
  but final newlines kept
```

#### Complex Data Structures
```yaml
# List of maps
users:
  - name: Alice
    role: admin
    permissions: [read, write, delete]
  - name: Bob
    role: user
    permissions: [read]
  - name: Charlie
    role: moderator
    permissions: [read, write]

# Map of lists
departments:
  engineering: [Alice, Bob, Charlie]
  marketing: [David, Eve]
  sales: [Frank, Grace, Henry]

# Map of maps
servers:
  web:
    hostname: web01.example.com
    ip: 192.168.1.10
    ports: [80, 443]
    config:
      max_connections: 1000
      timeout: 30
  db:
    hostname: db01.example.com
    ip: 192.168.1.20
    ports: [3306]
    config:
      max_connections: 100
      buffer_size: 1024

# List of lists
matrix:
  - [1, 2, 3]
  - [4, 5, 6]
  - [7, 8, 9]

# Mixed complex structure
application:
  name: MyApp
  version: 1.2.3
  environments:
    - name: development
      servers:
        - hostname: dev01
          services: [web, api]
        - hostname: dev02
          services: [database]
      config:
        debug: true
        log_level: DEBUG
    - name: production
      servers:
        - hostname: prod01
          services: [web, api]
        - hostname: prod02
          services: [web, api]
        - hostname: prod03
          services: [database]
      config:
        debug: false
        log_level: INFO
```

#### YAML Anchors and References
```yaml
# Define anchors with &
defaults: &default_config
  timeout: 30
  retries: 3
  debug: false

# Reference anchors with *
web_service:
  <<: *default_config
  port: 8080
  name: web

api_service:
  <<: *default_config
  port: 8081
  name: api
  debug: true  # Override default

# Multiple anchors
common_labels: &common_labels
  app: myapp
  version: v1.0

common_annotations: &common_annotations
  description: "My application"
  contact: "team@example.com"

# Using multiple references
deployment_metadata:
  labels:
    <<: *common_labels
    component: backend
  annotations:
    <<: *common_annotations
    deployment-date: "2023-12-01"
```

#### YAML Tags and Types
```yaml
# Explicit type tags
explicit_string: !!str 123
explicit_int: !!int "123"
explicit_float: !!float "3.14"
explicit_bool: !!bool "true"
explicit_null: !!null ""

# Binary data
binary_data: !!binary |
  R0lGODlhDAAMAIQAAP//9/X17unp5WZmZgAAAOfn515eXvPz7Y6OjuDg4J+fn5
  OTk6enp56enmlpaWNjY6Ojo4SEhP/++f/++f/++f/++f/++f/++f/++f/++f/+
  +f/++f/++f/++f/++f/++SH+Dk1hZGUgd2l0aCBHSU1QACwAAAAADAAMAAAFLC

# Set (unique values)
unique_items: !!set
  ? apple
  ? banana
  ? orange

# Ordered map
ordered_config: !!omap
  - first: 1
  - second: 2
  - third: 3
```

## Kubernetes Resource Structure

### Kubernetes-Specific YAML Patterns

#### Common API Versions
```yaml
# Core resources
apiVersion: v1              # Pod, Service, ConfigMap, Secret, PV, PVC

# Apps resources
apiVersion: apps/v1         # Deployment, ReplicaSet, StatefulSet, DaemonSet

# Batch resources
apiVersion: batch/v1        # Job
apiVersion: batch/v1beta1   # CronJob

# Networking resources
apiVersion: networking.k8s.io/v1  # Ingress, NetworkPolicy

# RBAC resources
apiVersion: rbac.authorization.k8s.io/v1  # Role, ClusterRole, RoleBinding

# Storage resources
apiVersion: storage.k8s.io/v1  # StorageClass
```

#### Kubernetes YAML Structure Patterns
```yaml
# Standard Kubernetes resource structure
apiVersion: apps/v1           # API version (string)
kind: Deployment              # Resource type (string)
metadata:                     # Metadata (map)
  name: my-app                # Name (string)
  namespace: default          # Namespace (string)
  labels:                     # Labels (map of strings)
    app: web
    version: v1.0
    environment: production
  annotations:                # Annotations (map of strings)
    description: "Web application"
    contact: "team@example.com"
spec:                         # Specification (map - varies by resource)
  replicas: 3                 # Replica count (integer)
  selector:                   # Selector (map)
    matchLabels:              # Match labels (map)
      app: web
    matchExpressions:         # Match expressions (list of maps)
      - key: environment
        operator: In
        values: [production, staging]
  template:                   # Pod template (map)
    metadata:                 # Template metadata (map)
      labels:                 # Template labels (map)
        app: web
        version: v1.0
    spec:                     # Pod specification (map)
      containers:             # Containers (list of maps)
        - name: web           # Container name (string)
          image: nginx:1.21   # Image (string)
          ports:              # Ports (list of maps)
            - containerPort: 80
              protocol: TCP
          env:                # Environment variables (list of maps)
            - name: ENV_VAR
              value: "production"
            - name: SECRET_VAR
              valueFrom:      # Value from source (map)
                secretKeyRef: # Secret reference (map)
                  name: app-secret
                  key: password
status:                       # Status (map - read-only)
  replicas: 3
  readyReplicas: 3
  availableReplicas: 3
```

#### List Patterns in Kubernetes
```yaml
# Simple string list
command: ["sh", "-c", "echo hello"]

# List of objects with different structures
containers:
  - name: web
    image: nginx:1.21
    ports:
      - containerPort: 80
  - name: sidecar
    image: busybox
    command: ["sleep", "3600"]

# List of maps with complex nested structures
volumes:
  - name: config-volume
    configMap:
      name: app-config
      items:
        - key: config.yaml
          path: app-config.yaml
        - key: logging.conf
          path: logging.conf
  - name: secret-volume
    secret:
      secretName: app-secret
      defaultMode: 0400
  - name: empty-volume
    emptyDir:
      sizeLimit: 1Gi

# List with conditional items
env:
  - name: NODE_ENV
    value: production
  - name: DATABASE_URL
    valueFrom:
      configMapKeyRef:
        name: db-config
        key: url
  - name: API_KEY
    valueFrom:
      secretKeyRef:
        name: api-secret
        key: key
        optional: false
```

#### Map Patterns in Kubernetes
```yaml
# Simple key-value maps
labels:
  app: web
  version: v1.0
  tier: frontend
  environment: production

# Nested maps
resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
    ephemeral-storage: "1Gi"
  limits:
    memory: "128Mi"
    cpu: "500m"
    ephemeral-storage: "2Gi"

# Maps with complex values
selector:
  matchLabels:
    app: web
  matchExpressions:
    - key: environment
      operator: In
      values: [production, staging]
    - key: tier
      operator: NotIn
      values: [cache]

# Maps in ConfigMaps and Secrets
data:
  config.yaml: |
    server:
      port: 8080
      host: 0.0.0.0
    database:
      host: db.example.com
      port: 5432
  app.properties: |
    debug=false
    log.level=INFO
    max.connections=100
  simple-key: simple-value
```

### Basic Resource Template
```yaml
apiVersion: v1              # API version
kind: Pod                   # Resource type
metadata:                   # Resource metadata
  name: my-pod
  namespace: default
  labels:
    app: web
    version: v1
  annotations:
    description: "Web server pod"
spec:                       # Resource specification
  containers:
  - name: web
    image: nginx:1.21
status:                     # Resource status (read-only)
  phase: Running
```

## YAML Best Practices

### Formatting and Style
```yaml
# Use 2 spaces for indentation (not tabs)
apiVersion: v1
kind: ConfigMap
metadata:
  name: style-example
data:
  # Use consistent indentation
  config.yaml: |
    server:
      port: 8080
      timeout: 30
    database:
      host: localhost
      port: 5432

# Use meaningful names
# Good
name: web-server-deployment
# Bad
name: deploy1

# Use consistent naming conventions
# kebab-case for resource names
name: my-web-app
# camelCase for keys when required by API
containerPort: 8080
```

### Comments and Documentation
```yaml
# Use comments to explain complex configurations
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  # Labels for resource organization
  labels:
    app: web
    component: frontend
    version: v1.2.3
  # Annotations for additional metadata
  annotations:
    description: "Main web application deployment"
    maintainer: "platform-team@company.com"
    last-updated: "2023-12-01"
spec:
  # Number of replicas for high availability
  replicas: 3
  
  # Rolling update strategy to minimize downtime
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1  # Allow 1 pod to be unavailable during updates
      maxSurge: 1        # Allow 1 extra pod during updates
```

### Multi-Document YAML
```yaml
# Separate multiple resources with ---
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  config.yaml: |
    debug: true
---
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  password: cGFzc3dvcmQ=
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: app
        image: myapp:v1.0
```

## Pods

### Basic Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
```

### Multi-Container Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
  containers:
  - name: web
    image: nginx:1.21
    ports:
    - containerPort: 80
    volumeMounts:
    - name: shared-data
      mountPath: /usr/share/nginx/html
  - name: sidecar
    image: busybox
    command: ['sh', '-c', 'while true; do echo "$(date): Hello from sidecar" > /data/index.html; sleep 30; done']
    volumeMounts:
    - name: shared-data
      mountPath: /data
  volumes:
  - name: shared-data
    emptyDir: {}
```

### Pod with Resource Limits
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-limited-pod
spec:
  containers:
  - name: app
    image: nginx:1.21
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
    env:
    - name: ENV_VAR
      value: "production"
    - name: SECRET_KEY
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: api-key
```

### Pod with Init Container
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-container-pod
spec:
  initContainers:
  - name: init-db
    image: busybox
    command: ['sh', '-c', 'until nslookup mysql-service; do echo waiting for mysql; sleep 2; done;']
  containers:
  - name: app
    image: nginx:1.21
    ports:
    - containerPort: 80
```

## Services

### ClusterIP Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-clusterip
spec:
  type: ClusterIP
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
```

### NodePort Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
    protocol: TCP
```

### LoadBalancer Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  loadBalancerSourceRanges:
  - 10.0.0.0/8
```

### Headless Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-headless
spec:
  clusterIP: None
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
```

### Service with Multiple Ports
```yaml
apiVersion: v1
kind: Service
metadata:
  name: multi-port-service
spec:
  selector:
    app: web
  ports:
  - name: http
    port: 80
    targetPort: 8080
  - name: https
    port: 443
    targetPort: 8443
  - name: metrics
    port: 9090
    targetPort: 9090
```

## Deployments

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
  name: rolling-update-deployment
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
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

### Deployment with Environment Variables
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: env-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: env-app
  template:
    metadata:
      labels:
        app: env-app
    spec:
      containers:
      - name: app
        image: nginx:1.21
        env:
        - name: DATABASE_URL
          value: "mysql://db:3306/myapp"
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: api-secret
              key: key
        - name: CONFIG_FILE
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: config.properties
        envFrom:
        - configMapRef:
            name: app-env-config
        - secretRef:
            name: app-env-secret
```

## ConfigMaps and Secrets

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
  config.json: |
    {
      "server": {
        "port": 8080,
        "host": "0.0.0.0"
      },
      "database": {
        "driver": "mysql",
        "pool_size": 10
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
---
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
type: kubernetes.io/tls
data:
  tls.crt: LS0tLS1CRUdJTi...  # base64 encoded certificate
  tls.key: LS0tLS1CRUdJTi...  # base64 encoded private key
```

### Using ConfigMap and Secret in Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: config-pod
spec:
  containers:
  - name: app
    image: nginx:1.21
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
    env:
    - name: DATABASE_HOST
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database.host
    - name: API_KEY
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: api-key
  volumes:
  - name: config-volume
    configMap:
      name: app-config
  - name: secret-volume
    secret:
      secretName: app-secret
```

## Volumes and Storage

### EmptyDir Volume
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: emptydir-pod
spec:
  containers:
  - name: app
    image: nginx:1.21
    volumeMounts:
    - name: cache-volume
      mountPath: /cache
  volumes:
  - name: cache-volume
    emptyDir:
      sizeLimit: 1Gi
```

### HostPath Volume
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hostpath-pod
spec:
  containers:
  - name: app
    image: nginx:1.21
    volumeMounts:
    - name: host-volume
      mountPath: /host-data
  volumes:
  - name: host-volume
    hostPath:
      path: /data
      type: Directory
```

### PersistentVolume and PersistentVolumeClaim
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-storage
spec:
  capacity:
    storage: 10Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /mnt/data
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-storage
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: manual
---
apiVersion: v1
kind: Pod
metadata:
  name: pvc-pod
spec:
  containers:
  - name: app
    image: nginx:1.21
    volumeMounts:
    - name: storage
      mountPath: /data
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: pvc-storage
```

### StorageClass
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
allowVolumeExpansion: true
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

## Namespaces

### Namespace Definition
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    environment: prod
    team: backend
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
    services: "5"
    persistentvolumeclaims: "4"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: production-limits
  namespace: production
spec:
  limits:
  - default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"
    type: Container
```

## Resource Management

### Resource Requests and Limits
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-pod
spec:
  containers:
  - name: app
    image: nginx:1.21
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
        ephemeral-storage: "1Gi"
      limits:
        memory: "128Mi"
        cpu: "500m"
        ephemeral-storage: "2Gi"
```

### Quality of Service Classes
```yaml
# Guaranteed QoS
apiVersion: v1
kind: Pod
metadata:
  name: guaranteed-pod
spec:
  containers:
  - name: app
    image: nginx:1.21
    resources:
      requests:
        memory: "128Mi"
        cpu: "500m"
      limits:
        memory: "128Mi"
        cpu: "500m"
---
# Burstable QoS
apiVersion: v1
kind: Pod
metadata:
  name: burstable-pod
spec:
  containers:
  - name: app
    image: nginx:1.21
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
---
# BestEffort QoS
apiVersion: v1
kind: Pod
metadata:
  name: besteffort-pod
spec:
  containers:
  - name: app
    image: nginx:1.21
```

### HorizontalPodAutoscaler
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-deployment
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

## Labels and Selectors

### Labels and Annotations
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: labeled-pod
  labels:
    app: web
    version: v1.2.3
    environment: production
    tier: frontend
    team: backend
  annotations:
    description: "Web server pod for production"
    contact: "team@example.com"
    version: "1.2.3"
    build-date: "2023-12-01"
spec:
  containers:
  - name: web
    image: nginx:1.21
```

### Label Selectors
```yaml
# Equality-based selector
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web
    environment: production
  ports:
  - port: 80
---
# Set-based selector
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  selector:
    matchLabels:
      app: web
    matchExpressions:
    - key: environment
      operator: In
      values: [production, staging]
    - key: tier
      operator: NotIn
      values: [cache]
    - key: version
      operator: Exists
  template:
    metadata:
      labels:
        app: web
        environment: production
        tier: frontend
    spec:
      containers:
      - name: web
        image: nginx:1.21
```

### Node Selector and Affinity
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: node-selector-pod
spec:
  nodeSelector:
    disktype: ssd
    zone: us-west-1a
  containers:
  - name: app
    image: nginx:1.21
---
apiVersion: v1
kind: Pod
metadata:
  name: node-affinity-pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values: [ssd, nvme]
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        preference:
          matchExpressions:
          - key: zone
            operator: In
            values: [us-west-1a]
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values: [database]
        topologyKey: kubernetes.io/hostname
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values: [web]
          topologyKey: kubernetes.io/hostname
  containers:
  - name: app
    image: nginx:1.21
```

## Advanced Workloads

### StatefulSet
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
```

### DaemonSet
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
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
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

### Job and CronJob
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: batch-job
spec:
  completions: 3
  parallelism: 2
  backoffLimit: 4
  template:
    spec:
      containers:
      - name: worker
        image: busybox
        command: ["sh", "-c", "echo Processing item $RANDOM && sleep 30"]
      restartPolicy: Never
---
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
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
```

## Practical Examples

### Complete Application Stack
```yaml
# Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: webapp
---
# ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: webapp-config
  namespace: webapp
data:
  database.host: "mysql-service"
  database.port: "3306"
  app.env: "production"
---
# Secret
apiVersion: v1
kind: Secret
metadata:
  name: webapp-secret
  namespace: webapp
type: Opaque
data:
  db-password: cGFzc3dvcmQ=
  api-key: bXlfc2VjcmV0X2tleQ==
---
# Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp-deployment
  namespace: webapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: webapp:v1.0
        ports:
        - containerPort: 8080
        env:
        - name: DATABASE_HOST
          valueFrom:
            configMapKeyRef:
              name: webapp-config
              key: database.host
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: webapp-secret
              key: db-password
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
---
# Service
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
  namespace: webapp
spec:
  selector:
    app: webapp
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

### Commands for Managing Resources
```bash
# Apply YAML files
kubectl apply -f pod.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Apply all YAML files in directory
kubectl apply -f ./manifests/

# Apply with namespace
kubectl apply -f pod.yaml -n production

# Dry run
kubectl apply -f deployment.yaml --dry-run=client -o yaml

# Validate YAML
kubectl apply -f deployment.yaml --validate=true --dry-run=client

# Get resources
kubectl get pods
kubectl get deployments
kubectl get services

# Describe resources
kubectl describe pod nginx-pod
kubectl describe deployment webapp-deployment

# Delete resources
kubectl delete -f pod.yaml
kubectl delete pod nginx-pod
kubectl delete deployment webapp-deployment

# Edit resources
kubectl edit deployment webapp-deployment
kubectl patch deployment webapp-deployment -p '{"spec":{"replicas":5}}'

# Scale deployments
kubectl scale deployment webapp-deployment --replicas=5

# Rollout management
kubectl rollout status deployment webapp-deployment
kubectl rollout history deployment webapp-deployment
kubectl rollout undo deployment webapp-deployment
```

---

**Next Steps**: Proceed to Task-k8s-04 for advanced Kubernetes workload concepts and comprehensive resource management.
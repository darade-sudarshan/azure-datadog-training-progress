# Task K8s-07: Kubernetes Security and Account Administration

## Overview
This task covers comprehensive Kubernetes security concepts including authentication, authorization, RBAC, service accounts, security contexts, network policies, and security best practices with detailed explanations and practical examples.

## Table of Contents
1. [Kubernetes Security Model](#kubernetes-security-model)
2. [Authentication](#authentication)
3. [Authorization (RBAC)](#authorization-rbac)
4. [Service Accounts](#service-accounts)
5. [Security Contexts](#security-contexts)
6. [Pod Security Standards](#pod-security-standards)
7. [Network Security](#network-security)
8. [Secrets Management](#secrets-management)
9. [Image Security](#image-security)
10. [Security Best Practices](#security-best-practices)

## Kubernetes Security Model

### Security Architecture Overview
Kubernetes security operates on multiple layers:
- **Authentication**: Who can access the cluster
- **Authorization**: What they can do
- **Admission Control**: What resources can be created
- **Security Contexts**: How pods run
- **Network Policies**: How pods communicate

### Security Principles
- **Defense in Depth**: Multiple security layers
- **Least Privilege**: Minimal required permissions
- **Zero Trust**: Verify everything, trust nothing
- **Immutable Infrastructure**: Read-only containers
- **Audit Logging**: Track all activities

```yaml
# Security overview diagram
apiVersion: v1
kind: ConfigMap
metadata:
  name: security-layers
data:
  layers: |
    1. Infrastructure Security (Nodes, Network)
    2. Cluster Security (API Server, etcd)
    3. Namespace Security (RBAC, Network Policies)
    4. Pod Security (Security Contexts, Pod Security Standards)
    5. Container Security (Images, Runtime)
    6. Application Security (Code, Dependencies)
```

## Authentication

### Authentication Methods

#### X.509 Client Certificates
```bash
# Generate client certificate
openssl genrsa -out user.key 2048
openssl req -new -key user.key -out user.csr -subj "/CN=john/O=developers"

# Sign certificate with cluster CA
openssl x509 -req -in user.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out user.crt -days 365

# Create kubeconfig with certificate
kubectl config set-credentials john --client-certificate=user.crt --client-key=user.key
kubectl config set-context john-context --cluster=kubernetes --user=john
```

#### Service Account Tokens
```yaml
# Service Account with token
apiVersion: v1
kind: ServiceAccount
metadata:
  name: api-service-account
  namespace: production
automountServiceAccountToken: true
---
# Secret for service account token
apiVersion: v1
kind: Secret
metadata:
  name: api-service-account-token
  namespace: production
  annotations:
    kubernetes.io/service-account.name: api-service-account
type: kubernetes.io/service-account-token
```

#### OIDC (OpenID Connect)
```yaml
# API Server configuration for OIDC
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
    - --oidc-issuer-url=https://accounts.google.com
    - --oidc-client-id=kubernetes
    - --oidc-username-claim=email
    - --oidc-groups-claim=groups
    - --oidc-ca-file=/etc/ssl/certs/ca-certificates.crt
```

#### Webhook Authentication
```yaml
# Webhook authentication configuration
apiVersion: v1
kind: Config
clusters:
- name: webhook-server
  cluster:
    server: https://auth-webhook.example.com/authenticate
    certificate-authority: /etc/webhook/ca.crt
users:
- name: webhook-client
  user:
    client-certificate: /etc/webhook/client.crt
    client-key: /etc/webhook/client.key
contexts:
- name: webhook
  context:
    cluster: webhook-server
    user: webhook-client
current-context: webhook
```

### Authentication Testing
```bash
# Test authentication
kubectl auth can-i create pods --as=john
kubectl auth can-i get secrets --as=system:serviceaccount:default:api-service-account

# Check current user
kubectl config view --minify -o jsonpath='{.contexts[0].context.user}'

# Impersonate user
kubectl get pods --as=john --as-group=developers
```

## Authorization (RBAC)

### RBAC Components Explanation

#### Roles and ClusterRoles
**Roles** define permissions within a namespace, while **ClusterRoles** define cluster-wide permissions.

```yaml
# Namespace-scoped Role
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: production
  name: pod-manager
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log", "pods/exec"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
- apiGroups: [""]
  resources: ["configmaps", "secrets"]
  verbs: ["get", "list"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "create", "update", "patch"]
---
# Cluster-wide ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-reader
rules:
- apiGroups: [""]
  resources: ["nodes", "nodes/status"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["metrics.k8s.io"]
  resources: ["nodes", "pods"]
  verbs: ["get", "list"]
```

#### RoleBindings and ClusterRoleBindings
**RoleBindings** grant permissions defined in a Role to users/groups within a namespace. **ClusterRoleBindings** grant cluster-wide permissions.

```yaml
# RoleBinding - grants Role permissions to users in a namespace
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-managers
  namespace: production
subjects:
- kind: User
  name: john
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
- kind: ServiceAccount
  name: deployment-manager
  namespace: production
roleRef:
  kind: Role
  name: pod-manager
  apiGroup: rbac.authorization.k8s.io
---
# ClusterRoleBinding - grants ClusterRole permissions cluster-wide
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: node-readers
subjects:
- kind: User
  name: monitoring-user
  apiGroup: rbac.authorization.k8s.io
- kind: ServiceAccount
  name: monitoring-service
  namespace: monitoring
roleRef:
  kind: ClusterRole
  name: node-reader
  apiGroup: rbac.authorization.k8s.io
```

### Common RBAC Patterns

#### Developer Role
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: development
  name: developer
rules:
# Full access to most resources in namespace
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets", "persistentvolumeclaims"]
  verbs: ["*"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "statefulsets", "daemonsets"]
  verbs: ["*"]
- apiGroups: ["batch"]
  resources: ["jobs", "cronjobs"]
  verbs: ["*"]
# Read-only access to nodes and namespaces
- apiGroups: [""]
  resources: ["nodes", "namespaces"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developers
  namespace: development
subjects:
- kind: Group
  name: developers
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
```

#### Read-Only Role
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: read-only
rules:
- apiGroups: [""]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["batch"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["networking.k8s.io"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-only-users
subjects:
- kind: Group
  name: viewers
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: read-only
  apiGroup: rbac.authorization.k8s.io
```

#### Namespace Admin Role
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: production
  name: namespace-admin
rules:
# Full access to all resources in namespace
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: namespace-admins
  namespace: production
subjects:
- kind: User
  name: prod-admin
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: namespace-admin
  apiGroup: rbac.authorization.k8s.io
```

### RBAC Testing and Debugging
```bash
# Check if user can perform action
kubectl auth can-i create pods --as=john
kubectl auth can-i delete secrets --as=john --namespace=production

# Check permissions for service account
kubectl auth can-i list pods --as=system:serviceaccount:default:my-service-account

# List all permissions for user
kubectl auth can-i --list --as=john

# Check what user can do in specific namespace
kubectl auth can-i --list --as=john --namespace=production

# Debug RBAC issues
kubectl describe rolebinding pod-managers -n production
kubectl describe clusterrolebinding cluster-admin

# Get all RBAC resources
kubectl get roles,rolebindings,clusterroles,clusterrolebindings
```

## Service Accounts

### Service Account Concepts
Service accounts provide an identity for processes running in pods. They are used for:
- **Pod Authentication**: Authenticate pods to the API server
- **RBAC Integration**: Assign permissions to pods
- **Token Management**: Automatic token mounting
- **Cross-Namespace Access**: Service-to-service communication

### Creating and Managing Service Accounts
```yaml
# Basic Service Account
apiVersion: v1
kind: ServiceAccount
metadata:
  name: webapp-service-account
  namespace: production
  labels:
    app: webapp
  annotations:
    description: "Service account for web application"
automountServiceAccountToken: true
---
# Service Account with Image Pull Secrets
apiVersion: v1
kind: ServiceAccount
metadata:
  name: private-registry-sa
  namespace: production
imagePullSecrets:
- name: private-registry-secret
automountServiceAccountToken: true
---
# Disable automatic token mounting
apiVersion: v1
kind: ServiceAccount
metadata:
  name: no-token-sa
  namespace: production
automountServiceAccountToken: false
```

### Service Account Tokens
```yaml
# Manual token creation (Kubernetes 1.24+)
apiVersion: v1
kind: Secret
metadata:
  name: webapp-sa-token
  namespace: production
  annotations:
    kubernetes.io/service-account.name: webapp-service-account
type: kubernetes.io/service-account-token
---
# TokenRequest API usage
apiVersion: v1
kind: Pod
metadata:
  name: token-request-example
spec:
  serviceAccountName: webapp-service-account
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: service-account-token
      mountPath: /var/run/secrets/tokens
      readOnly: true
  volumes:
  - name: service-account-token
    projected:
      sources:
      - serviceAccountToken:
          path: token
          expirationSeconds: 3600
          audience: api
```

### Using Service Accounts in Pods
```yaml
# Pod with custom service account
apiVersion: v1
kind: Pod
metadata:
  name: webapp-pod
  namespace: production
spec:
  serviceAccountName: webapp-service-account
  containers:
  - name: webapp
    image: webapp:v1.0
    env:
    - name: KUBERNETES_NAMESPACE
      valueFrom:
        fieldRef:
          fieldPath: metadata.namespace
    - name: SERVICE_ACCOUNT
      valueFrom:
        fieldRef:
          fieldPath: spec.serviceAccountName
---
# Deployment with service account
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      serviceAccountName: api-service-account
      containers:
      - name: api
        image: api:v1.0
        ports:
        - containerPort: 8080
```

### Service Account RBAC Integration
```yaml
# Role for service account
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: production
  name: configmap-reader
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get"]
---
# Bind role to service account
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: configmap-reader-binding
  namespace: production
subjects:
- kind: ServiceAccount
  name: webapp-service-account
  namespace: production
roleRef:
  kind: Role
  name: configmap-reader
  apiGroup: rbac.authorization.k8s.io
```

## Security Contexts

### Security Context Concepts
Security contexts define privilege and access control settings for pods and containers:
- **User and Group IDs**: Run as specific user/group
- **Capabilities**: Linux capabilities management
- **SELinux**: Security-Enhanced Linux labels
- **Seccomp**: Secure computing mode
- **AppArmor**: Application armor profiles

### Pod Security Context
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-context-pod
spec:
  # Pod-level security context
  securityContext:
    runAsUser: 1000          # Run as user ID 1000
    runAsGroup: 3000         # Run as group ID 3000
    runAsNonRoot: true       # Ensure container runs as non-root
    fsGroup: 2000            # Set filesystem group ID
    fsGroupChangePolicy: "OnRootMismatch"  # When to change fs ownership
    seccompProfile:          # Seccomp profile
      type: RuntimeDefault
    seLinuxOptions:          # SELinux options
      level: "s0:c123,c456"
    sysctls:                 # Kernel parameters
    - name: net.core.somaxconn
      value: "1024"
  containers:
  - name: secure-container
    image: nginx:1.21
    # Container-level security context (overrides pod-level)
    securityContext:
      allowPrivilegeEscalation: false  # Prevent privilege escalation
      readOnlyRootFilesystem: true     # Read-only root filesystem
      runAsNonRoot: true               # Run as non-root user
      runAsUser: 1001                  # Override pod-level user
      capabilities:                    # Linux capabilities
        drop:
        - ALL                          # Drop all capabilities
        add:
        - NET_BIND_SERVICE             # Add specific capability
      seccompProfile:
        type: Localhost
        localhostProfile: profiles/audit.json
    volumeMounts:
    - name: tmp-volume
      mountPath: /tmp
    - name: cache-volume
      mountPath: /var/cache/nginx
  volumes:
  - name: tmp-volume
    emptyDir: {}
  - name: cache-volume
    emptyDir: {}
```

### Advanced Security Context Examples
```yaml
# Privileged container (avoid in production)
apiVersion: v1
kind: Pod
metadata:
  name: privileged-pod
spec:
  containers:
  - name: privileged-container
    image: nginx
    securityContext:
      privileged: true
      capabilities:
        add:
        - SYS_ADMIN
        - NET_ADMIN
---
# Highly restricted container
apiVersion: v1
kind: Pod
metadata:
  name: restricted-pod
spec:
  securityContext:
    runAsUser: 65534        # nobody user
    runAsGroup: 65534       # nobody group
    runAsNonRoot: true
    fsGroup: 65534
  containers:
  - name: restricted-container
    image: nginx:1.21
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      capabilities:
        drop:
        - ALL
      seccompProfile:
        type: RuntimeDefault
    resources:
      limits:
        memory: "128Mi"
        cpu: "100m"
      requests:
        memory: "64Mi"
        cpu: "50m"
```

## Pod Security Standards

### Pod Security Standards Overview
Pod Security Standards define three policies:
- **Privileged**: Unrestricted policy (no restrictions)
- **Baseline**: Minimally restrictive policy (prevents known privilege escalations)
- **Restricted**: Heavily restricted policy (follows pod hardening best practices)

### Pod Security Standards Implementation
```yaml
# Namespace with Pod Security Standards
apiVersion: v1
kind: Namespace
metadata:
  name: secure-namespace
  labels:
    # Enforce restricted policy
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/enforce-version: v1.28
    # Warn on baseline violations
    pod-security.kubernetes.io/warn: baseline
    pod-security.kubernetes.io/warn-version: v1.28
    # Audit privileged violations
    pod-security.kubernetes.io/audit: privileged
    pod-security.kubernetes.io/audit-version: v1.28
---
# Pod that complies with restricted policy
apiVersion: v1
kind: Pod
metadata:
  name: compliant-pod
  namespace: secure-namespace
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: nginx:1.21
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      runAsUser: 1000
      capabilities:
        drop:
        - ALL
      seccompProfile:
        type: RuntimeDefault
    resources:
      limits:
        memory: "128Mi"
        cpu: "100m"
      requests:
        memory: "64Mi"
        cpu: "50m"
    volumeMounts:
    - name: tmp
      mountPath: /tmp
  volumes:
  - name: tmp
    emptyDir: {}
```

### Pod Security Policy (Deprecated)
```yaml
# Pod Security Policy (deprecated in v1.21, removed in v1.25)
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted-psp
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
```

## Network Security

### Network Policies
Network policies control traffic flow between pods and external endpoints.

```yaml
# Deny all ingress traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
---
# Allow specific ingress traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: backend
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
  - to: []  # Allow DNS
    ports:
    - protocol: UDP
      port: 53
---
# Database isolation policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-isolation
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: backend
    ports:
    - protocol: TCP
      port: 3306
    - protocol: TCP
      port: 5432
  egress:
  - to: []
    ports:
    - protocol: UDP
      port: 53  # DNS only
```

### Service Mesh Security
```yaml
# Istio security policy example
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: backend-policy
  namespace: production
spec:
  selector:
    matchLabels:
      app: backend
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/production/sa/frontend-sa"]
  - to:
    - operation:
        methods: ["GET", "POST"]
        paths: ["/api/*"]
---
# Istio peer authentication
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: production
spec:
  mtls:
    mode: STRICT
```

## Secrets Management

### Kubernetes Secrets
```yaml
# Generic secret
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  namespace: production
type: Opaque
data:
  username: YWRtaW4=           # base64 encoded
  password: cGFzc3dvcmQ=       # base64 encoded
  api-key: bXlfc2VjcmV0X2tleQ== # base64 encoded
stringData:
  config.yaml: |               # Plain text (will be base64 encoded)
    database:
      host: db.example.com
      port: 5432
---
# TLS secret
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
  namespace: production
type: kubernetes.io/tls
data:
  tls.crt: LS0tLS1CRUdJTi...    # base64 encoded certificate
  tls.key: LS0tLS1CRUdJTi...    # base64 encoded private key
---
# Docker registry secret
apiVersion: v1
kind: Secret
metadata:
  name: registry-secret
  namespace: production
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: eyJhdXRocyI6eyJyZWdpc3RyeS5leGFtcGxlLmNvbSI6eyJ1c2VybmFtZSI6InVzZXIiLCJwYXNzd29yZCI6InBhc3MiLCJhdXRoIjoiZFhObGNqcHdZWE56In19fQ==
```

### External Secrets Management
```yaml
# External Secrets Operator
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
  namespace: production
spec:
  provider:
    vault:
      server: "https://vault.example.com"
      path: "secret"
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "example-role"
          serviceAccountRef:
            name: "external-secrets-sa"
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: vault-secret
  namespace: production
spec:
  refreshInterval: 15s
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: app-secret
    creationPolicy: Owner
  data:
  - secretKey: password
    remoteRef:
      key: secret/data/database
      property: password
```

### Secret Security Best Practices
```yaml
# Secure secret usage in pod
apiVersion: v1
kind: Pod
metadata:
  name: secure-secret-pod
spec:
  serviceAccountName: app-service-account
  containers:
  - name: app
    image: app:v1.0
    env:
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: app-secrets
          key: password
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: app-secrets
      defaultMode: 0400  # Read-only for owner
      items:
      - key: config.yaml
        path: config.yaml
        mode: 0400
```

## Image Security

### Image Security Scanning
```yaml
# Pod with image security annotations
apiVersion: v1
kind: Pod
metadata:
  name: scanned-pod
  annotations:
    # Image scanning results
    security.alpha.kubernetes.io/sysctls: net.core.somaxconn=1024
    container.apparmor.security.beta.kubernetes.io/app: runtime/default
spec:
  containers:
  - name: app
    image: nginx:1.21@sha256:abc123...  # Use digest for immutability
    imagePullPolicy: Always
    securityContext:
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      runAsUser: 1000
```

### Image Pull Policies and Security
```yaml
# Secure image pull configuration
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
    spec:
      serviceAccountName: secure-app-sa
      imagePullSecrets:
      - name: private-registry-secret
      containers:
      - name: app
        image: private-registry.example.com/app:v1.2.3@sha256:def456...
        imagePullPolicy: Always
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          capabilities:
            drop:
            - ALL
```

### Admission Controllers for Image Security
```yaml
# OPA Gatekeeper policy for image security
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8srequiredimageregistry
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredImageRegistry
      validation:
        properties:
          registries:
            type: array
            items:
              type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredimageregistry
        
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not starts_with(container.image, input.parameters.registries[_])
          msg := sprintf("Image '%v' is not from approved registry", [container.image])
        }
---
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredImageRegistry
metadata:
  name: must-use-approved-registry
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
  parameters:
    registries:
      - "registry.example.com/"
      - "gcr.io/my-project/"
```

## Security Best Practices

### Cluster Hardening Checklist
```yaml
# Security hardening configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: security-checklist
data:
  cluster-hardening: |
    ✓ Enable RBAC
    ✓ Use Network Policies
    ✓ Enable Pod Security Standards
    ✓ Secure etcd with TLS
    ✓ Enable audit logging
    ✓ Use admission controllers
    ✓ Regularly update Kubernetes
    ✓ Scan container images
    ✓ Use read-only root filesystems
    ✓ Run containers as non-root
    ✓ Limit resource usage
    ✓ Use secrets for sensitive data
    ✓ Enable encryption at rest
    ✓ Monitor and alert on security events
```

### Security Monitoring and Auditing
```yaml
# Audit policy configuration
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
# Log all requests at metadata level
- level: Metadata
  resources:
  - group: ""
    resources: ["secrets", "configmaps"]
# Log all authentication failures
- level: Request
  users: ["system:anonymous"]
  verbs: ["*"]
# Log all privileged operations
- level: RequestResponse
  resources:
  - group: ""
    resources: ["pods/exec", "pods/portforward", "pods/proxy"]
# Log all RBAC changes
- level: RequestResponse
  resources:
  - group: "rbac.authorization.k8s.io"
    resources: ["*"]
```

### Security Automation Example
```yaml
# Falco security monitoring
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: falco
  namespace: falco-system
spec:
  selector:
    matchLabels:
      app: falco
  template:
    metadata:
      labels:
        app: falco
    spec:
      serviceAccountName: falco
      hostNetwork: true
      hostPID: true
      containers:
      - name: falco
        image: falcosecurity/falco:latest
        securityContext:
          privileged: true
        volumeMounts:
        - name: dev
          mountPath: /host/dev
        - name: proc
          mountPath: /host/proc
          readOnly: true
        - name: boot
          mountPath: /host/boot
          readOnly: true
        - name: lib-modules
          mountPath: /host/lib/modules
          readOnly: true
        - name: usr
          mountPath: /host/usr
          readOnly: true
        - name: etc
          mountPath: /host/etc
          readOnly: true
      volumes:
      - name: dev
        hostPath:
          path: /dev
      - name: proc
        hostPath:
          path: /proc
      - name: boot
        hostPath:
          path: /boot
      - name: lib-modules
        hostPath:
          path: /lib/modules
      - name: usr
        hostPath:
          path: /usr
      - name: etc
        hostPath:
          path: /etc
```

### Security Commands and Testing
```bash
# RBAC testing
kubectl auth can-i create pods --as=user1
kubectl auth can-i --list --as=system:serviceaccount:default:my-sa

# Security scanning
kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.securityContext}{"\n"}{end}'

# Check for privileged containers
kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].securityContext.privileged}{"\n"}{end}'

# Audit RBAC permissions
kubectl get clusterrolebindings -o wide
kubectl get rolebindings --all-namespaces -o wide

# Check network policies
kubectl get networkpolicies --all-namespaces

# Validate pod security standards
kubectl label namespace default pod-security.kubernetes.io/enforce=restricted --dry-run=server

# Check for security issues
kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].securityContext.runAsRoot}{"\n"}{end}'
```

---

**Next Steps**: Proceed to Task-k8s-08 for advanced Kubernetes monitoring, logging, and observability concepts.
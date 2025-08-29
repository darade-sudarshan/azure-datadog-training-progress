# Task K8s-06: kubectl Installation and Command Reference

## Overview
This task covers kubectl installation procedures for different platforms and provides a comprehensive reference of kubectl commands with practical examples.

## Table of Contents
1. [kubectl Installation](#kubectl-installation)
2. [kubectl Configuration](#kubectl-configuration)
3. [Basic Commands](#basic-commands)
4. [Resource Management](#resource-management)
5. [Cluster Management](#cluster-management)
6. [Debugging and Troubleshooting](#debugging-and-troubleshooting)
7. [Advanced Commands](#advanced-commands)
8. [Plugin Management](#plugin-management)
9. [Command Shortcuts](#command-shortcuts)
10. [Practical Examples](#practical-examples)

## kubectl Installation

### Linux Installation

#### Method 1: Download Binary
```bash
# Download latest stable version
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Download specific version
curl -LO https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl

# Validate binary (optional)
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify installation
kubectl version --client
```

#### Method 2: Package Manager (Ubuntu/Debian)
```bash
# Update package index
sudo apt-get update

# Install packages needed for apt repository
sudo apt-get install -y ca-certificates curl

# Download Google Cloud public signing key
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Add Kubernetes apt repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update package index with new repository
sudo apt-get update

# Install kubectl
sudo apt-get install -y kubectl

# Verify installation
kubectl version --client
```

#### Method 3: Snap Package
```bash
# Install kubectl via snap
sudo snap install kubectl --classic

# Verify installation
kubectl version --client
```

#### Method 4: CentOS/RHEL/Fedora
```bash
# Add Kubernetes repository
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Install kubectl
sudo yum install -y kubectl

# For Fedora
sudo dnf install -y kubectl

# Verify installation
kubectl version --client
```

### macOS Installation

#### Method 1: Homebrew
```bash
# Install kubectl using Homebrew
brew install kubectl

# Verify installation
kubectl version --client
```

#### Method 2: MacPorts
```bash
# Install kubectl using MacPorts
sudo port selfupdate
sudo port install kubectl

# Verify installation
kubectl version --client
```

#### Method 3: Download Binary
```bash
# Download latest stable version
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"

# For Apple Silicon Macs
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl"

# Make binary executable
chmod +x ./kubectl

# Move to PATH
sudo mv ./kubectl /usr/local/bin/kubectl
sudo chown root: /usr/local/bin/kubectl

# Verify installation
kubectl version --client
```

### Windows Installation

#### Method 1: Chocolatey
```powershell
# Install kubectl using Chocolatey
choco install kubernetes-cli

# Verify installation
kubectl version --client
```

#### Method 2: Scoop
```powershell
# Install kubectl using Scoop
scoop install kubectl

# Verify installation
kubectl version --client
```

#### Method 3: Download Binary
```powershell
# Download latest stable version
curl.exe -LO "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe"

# Add to PATH or move to a directory in PATH
# Verify installation
kubectl version --client
```

#### Method 4: Windows Package Manager
```powershell
# Install using winget
winget install -e --id Kubernetes.kubectl

# Verify installation
kubectl version --client
```

### Docker Desktop Installation
```bash
# kubectl is included with Docker Desktop
# Enable Kubernetes in Docker Desktop settings
# Verify installation
kubectl version --client
kubectl cluster-info
```

## kubectl Configuration

### Kubeconfig Setup
```bash
# View current configuration
kubectl config view

# View current context
kubectl config current-context

# List all contexts
kubectl config get-contexts

# Switch context
kubectl config use-context my-cluster

# Set cluster
kubectl config set-cluster my-cluster --server=https://k8s-api.example.com

# Set credentials
kubectl config set-credentials my-user --token=bearer_token

# Set context
kubectl config set-context my-context --cluster=my-cluster --user=my-user

# Set namespace for context
kubectl config set-context --current --namespace=my-namespace

# Merge kubeconfig files
KUBECONFIG=~/.kube/config:~/.kube/config2 kubectl config view --merge --flatten > ~/.kube/merged_config
```

### Environment Variables
```bash
# Set kubeconfig file location
export KUBECONFIG=~/.kube/config

# Set default namespace
export KUBECTL_NAMESPACE=my-namespace

# Set context
export KUBECTL_CONTEXT=my-context
```

## Basic Commands

### Cluster Information
```bash
# Get cluster information
kubectl cluster-info

# Get cluster information dump
kubectl cluster-info dump

# Get API versions
kubectl api-versions

# Get API resources
kubectl api-resources

# Get component statuses
kubectl get componentstatuses
kubectl get cs
```

### Version Information
```bash
# Get client and server version
kubectl version

# Get client version only
kubectl version --client

# Get server version only
kubectl version --short
```

## Resource Management

### Get Resources
```bash
# Get all resources
kubectl get all

# Get specific resource types
kubectl get pods
kubectl get services
kubectl get deployments
kubectl get nodes
kubectl get namespaces

# Get resources with wide output
kubectl get pods -o wide
kubectl get nodes -o wide

# Get resources in all namespaces
kubectl get pods --all-namespaces
kubectl get pods -A

# Get resources in specific namespace
kubectl get pods -n kube-system

# Get resources with labels
kubectl get pods --show-labels
kubectl get pods -l app=nginx
kubectl get pods -l 'environment in (production,staging)'

# Get resources with custom columns
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName

# Get resources sorted
kubectl get pods --sort-by=.metadata.creationTimestamp
kubectl get pods --sort-by=.status.startTime

# Watch resources
kubectl get pods --watch
kubectl get pods -w

# Get resource YAML/JSON
kubectl get pod nginx-pod -o yaml
kubectl get pod nginx-pod -o json
```

### Describe Resources
```bash
# Describe specific resources
kubectl describe pod nginx-pod
kubectl describe service nginx-service
kubectl describe node worker-node-1
kubectl describe deployment nginx-deployment

# Describe resources by label
kubectl describe pods -l app=nginx

# Describe all resources of a type
kubectl describe pods
kubectl describe services
```

### Create Resources
```bash
# Create from file
kubectl create -f pod.yaml
kubectl create -f deployment.yaml

# Create from URL
kubectl create -f https://example.com/pod.yaml

# Create from directory
kubectl create -f ./manifests/

# Create from stdin
cat pod.yaml | kubectl create -f -

# Create specific resource types
kubectl create deployment nginx --image=nginx
kubectl create service clusterip nginx --tcp=80:80
kubectl create configmap app-config --from-file=config.properties
kubectl create secret generic app-secret --from-literal=password=secret123

# Create namespace
kubectl create namespace production

# Create service account
kubectl create serviceaccount my-service-account

# Create role
kubectl create role pod-reader --verb=get --verb=list --verb=watch --resource=pods

# Create rolebinding
kubectl create rolebinding read-pods --role=pod-reader --user=jane

# Create job
kubectl create job hello --image=busybox -- echo "Hello World"

# Create cronjob
kubectl create cronjob hello --image=busybox --schedule="*/1 * * * *" -- echo "Hello World"
```

### Apply Resources
```bash
# Apply configuration
kubectl apply -f pod.yaml
kubectl apply -f deployment.yaml

# Apply from directory
kubectl apply -f ./manifests/

# Apply with recursive directory search
kubectl apply -R -f ./manifests/

# Apply from URL
kubectl apply -f https://example.com/deployment.yaml

# Apply with dry run
kubectl apply -f deployment.yaml --dry-run=client
kubectl apply -f deployment.yaml --dry-run=server

# Apply with validation
kubectl apply -f deployment.yaml --validate=true

# Apply and record change
kubectl apply -f deployment.yaml --record
```

### Delete Resources
```bash
# Delete from file
kubectl delete -f pod.yaml
kubectl delete -f deployment.yaml

# Delete specific resources
kubectl delete pod nginx-pod
kubectl delete service nginx-service
kubectl delete deployment nginx-deployment

# Delete by label
kubectl delete pods -l app=nginx
kubectl delete all -l app=nginx

# Delete all resources of a type
kubectl delete pods --all
kubectl delete services --all

# Delete with grace period
kubectl delete pod nginx-pod --grace-period=30

# Force delete
kubectl delete pod nginx-pod --force --grace-period=0

# Delete namespace (and all resources in it)
kubectl delete namespace production

# Delete multiple resources
kubectl delete pod,service nginx
```

### Edit Resources
```bash
# Edit resource in default editor
kubectl edit pod nginx-pod
kubectl edit deployment nginx-deployment
kubectl edit service nginx-service

# Edit with specific editor
EDITOR=vim kubectl edit pod nginx-pod

# Edit multiple resources
kubectl edit deployment,service nginx
```

### Patch Resources
```bash
# Strategic merge patch
kubectl patch deployment nginx -p '{"spec":{"replicas":3}}'

# JSON merge patch
kubectl patch pod nginx --type='merge' -p '{"spec":{"containers":[{"name":"nginx","image":"nginx:1.21"}]}}'

# JSON patch
kubectl patch pod nginx --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/image", "value":"nginx:1.21"}]'

# Patch from file
kubectl patch deployment nginx --patch-file patch.yaml
```

### Replace Resources
```bash
# Replace resource
kubectl replace -f pod.yaml

# Replace with force (delete and recreate)
kubectl replace -f pod.yaml --force

# Replace from stdin
cat pod.yaml | kubectl replace -f -
```

## Cluster Management

### Node Management
```bash
# Get nodes
kubectl get nodes
kubectl get nodes -o wide

# Describe node
kubectl describe node worker-node-1

# Cordon node (mark as unschedulable)
kubectl cordon worker-node-1

# Uncordon node
kubectl uncordon worker-node-1

# Drain node (evict pods)
kubectl drain worker-node-1 --ignore-daemonsets --delete-emptydir-data

# Taint node
kubectl taint nodes worker-node-1 key=value:NoSchedule

# Remove taint
kubectl taint nodes worker-node-1 key=value:NoSchedule-

# Label node
kubectl label nodes worker-node-1 disktype=ssd

# Remove label
kubectl label nodes worker-node-1 disktype-
```

### Namespace Management
```bash
# Get namespaces
kubectl get namespaces
kubectl get ns

# Create namespace
kubectl create namespace production

# Delete namespace
kubectl delete namespace production

# Set default namespace for context
kubectl config set-context --current --namespace=production
```

### Resource Quotas and Limits
```bash
# Get resource quotas
kubectl get resourcequotas
kubectl get quota

# Describe resource quota
kubectl describe quota compute-quota

# Get limit ranges
kubectl get limitranges
kubectl get limits

# Describe limit range
kubectl describe limitrange mem-limit-range
```

## Debugging and Troubleshooting

### Logs
```bash
# Get pod logs
kubectl logs nginx-pod

# Get logs from specific container
kubectl logs nginx-pod -c nginx-container

# Follow logs
kubectl logs -f nginx-pod

# Get previous container logs
kubectl logs nginx-pod --previous

# Get logs with timestamps
kubectl logs nginx-pod --timestamps

# Get logs since specific time
kubectl logs nginx-pod --since=1h
kubectl logs nginx-pod --since-time=2023-12-01T10:00:00Z

# Get logs with tail
kubectl logs nginx-pod --tail=50

# Get logs from all containers in pod
kubectl logs nginx-pod --all-containers

# Get logs from deployment
kubectl logs deployment/nginx-deployment

# Get logs from multiple pods
kubectl logs -l app=nginx
```

### Execute Commands
```bash
# Execute command in pod
kubectl exec nginx-pod -- ls /

# Execute interactive shell
kubectl exec -it nginx-pod -- /bin/bash
kubectl exec -it nginx-pod -- /bin/sh

# Execute command in specific container
kubectl exec nginx-pod -c nginx-container -- ls /

# Execute command with TTY
kubectl exec -t nginx-pod -- ls /
```

### Port Forwarding
```bash
# Forward local port to pod
kubectl port-forward nginx-pod 8080:80

# Forward to service
kubectl port-forward service/nginx-service 8080:80

# Forward to deployment
kubectl port-forward deployment/nginx-deployment 8080:80

# Forward with specific local address
kubectl port-forward --address 0.0.0.0 nginx-pod 8080:80

# Forward multiple ports
kubectl port-forward nginx-pod 8080:80 8443:443
```

### Copy Files
```bash
# Copy file from pod to local
kubectl cp nginx-pod:/etc/nginx/nginx.conf ./nginx.conf

# Copy file from local to pod
kubectl cp ./nginx.conf nginx-pod:/etc/nginx/nginx.conf

# Copy from specific container
kubectl cp nginx-pod:/etc/nginx/nginx.conf ./nginx.conf -c nginx-container

# Copy directory
kubectl cp nginx-pod:/etc/nginx/ ./nginx-config/
```

### Resource Usage
```bash
# Get resource usage for nodes
kubectl top nodes

# Get resource usage for pods
kubectl top pods

# Get resource usage for pods in namespace
kubectl top pods -n kube-system

# Get resource usage with containers
kubectl top pods --containers

# Sort by CPU usage
kubectl top pods --sort-by=cpu

# Sort by memory usage
kubectl top pods --sort-by=memory
```

## Advanced Commands

### Scaling
```bash
# Scale deployment
kubectl scale deployment nginx-deployment --replicas=5

# Scale multiple deployments
kubectl scale deployment nginx-deployment web-deployment --replicas=3

# Scale based on condition
kubectl scale deployment nginx-deployment --replicas=5 --current-replicas=3

# Autoscale deployment
kubectl autoscale deployment nginx-deployment --min=2 --max=10 --cpu-percent=80
```

### Rolling Updates
```bash
# Update deployment image
kubectl set image deployment/nginx-deployment nginx=nginx:1.21

# Update multiple containers
kubectl set image deployment/nginx-deployment nginx=nginx:1.21 sidecar=sidecar:v2

# Update from file
kubectl apply -f deployment.yaml

# Check rollout status
kubectl rollout status deployment/nginx-deployment

# Check rollout history
kubectl rollout history deployment/nginx-deployment

# Rollback to previous version
kubectl rollout undo deployment/nginx-deployment

# Rollback to specific revision
kubectl rollout undo deployment/nginx-deployment --to-revision=2

# Pause rollout
kubectl rollout pause deployment/nginx-deployment

# Resume rollout
kubectl rollout resume deployment/nginx-deployment

# Restart deployment
kubectl rollout restart deployment/nginx-deployment
```

### Resource Management
```bash
# Set resources
kubectl set resources deployment nginx-deployment -c=nginx --limits=cpu=200m,memory=512Mi --requests=cpu=100m,memory=256Mi

# Set environment variables
kubectl set env deployment/nginx-deployment ENV_VAR=value

# Set environment from configmap
kubectl set env deployment/nginx-deployment --from=configmap/app-config

# Set environment from secret
kubectl set env deployment/nginx-deployment --from=secret/app-secret

# Remove environment variable
kubectl set env deployment/nginx-deployment ENV_VAR-
```

### Labels and Annotations
```bash
# Add label
kubectl label pods nginx-pod app=nginx

# Update label
kubectl label pods nginx-pod app=web --overwrite

# Remove label
kubectl label pods nginx-pod app-

# Add annotation
kubectl annotate pods nginx-pod description="Web server pod"

# Update annotation
kubectl annotate pods nginx-pod description="Updated web server pod" --overwrite

# Remove annotation
kubectl annotate pods nginx-pod description-
```

## Plugin Management

### Krew Plugin Manager
```bash
# Install krew
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

# Add to PATH
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# List available plugins
kubectl krew search

# Install plugin
kubectl krew install ctx
kubectl krew install ns
kubectl krew install tree

# List installed plugins
kubectl krew list

# Update plugins
kubectl krew upgrade

# Uninstall plugin
kubectl krew uninstall ctx
```

### Popular Plugins
```bash
# Context switching
kubectl ctx                    # List contexts
kubectl ctx production         # Switch to production context

# Namespace switching
kubectl ns                     # List namespaces
kubectl ns kube-system         # Switch to kube-system namespace

# Resource tree view
kubectl tree deployment nginx-deployment

# Resource capacity
kubectl resource-capacity

# Who can access resources
kubectl who-can create pods

# View resource relationships
kubectl graph deployment nginx-deployment
```

## Command Shortcuts

### Resource Type Shortcuts
```bash
# Common shortcuts
kubectl get po          # pods
kubectl get svc         # services
kubectl get deploy      # deployments
kubectl get rs          # replicasets
kubectl get ds          # daemonsets
kubectl get sts         # statefulsets
kubectl get cm          # configmaps
kubectl get secrets     # secrets
kubectl get ns          # namespaces
kubectl get no          # nodes
kubectl get pv          # persistentvolumes
kubectl get pvc         # persistentvolumeclaims
kubectl get ing         # ingress
kubectl get netpol      # networkpolicies
kubectl get hpa         # horizontalpodautoscalers
kubectl get cj          # cronjobs
```

### Useful Aliases
```bash
# Add to ~/.bashrc or ~/.zshrc
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kdel='kubectl delete'
alias kl='kubectl logs'
alias ke='kubectl exec -it'
alias kpf='kubectl port-forward'
alias kctx='kubectl config current-context'
alias kns='kubectl config view --minify --output "jsonpath={..namespace}"'

# Usage examples
k get po
kg svc
kd pod nginx-pod
kdel deployment nginx-deployment
kl nginx-pod
ke nginx-pod -- /bin/bash
kpf nginx-pod 8080:80
```

## Practical Examples

### Complete Workflow Example
```bash
# 1. Create namespace
kubectl create namespace webapp

# 2. Set namespace context
kubectl config set-context --current --namespace=webapp

# 3. Create configmap
kubectl create configmap app-config \
  --from-literal=database.host=mysql.webapp.svc.cluster.local \
  --from-literal=database.port=3306

# 4. Create secret
kubectl create secret generic app-secret \
  --from-literal=database.password=secretpassword \
  --from-literal=api.key=myapikey123

# 5. Apply deployment
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  labels:
    app: webapp
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
        image: nginx:1.21
        ports:
        - containerPort: 80
        env:
        - name: DB_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database.host
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: database.password
EOF

# 6. Create service
kubectl expose deployment webapp --port=80 --type=ClusterIP

# 7. Check deployment status
kubectl get deployments
kubectl rollout status deployment/webapp

# 8. Check pods
kubectl get pods -l app=webapp

# 9. Check service
kubectl get service webapp

# 10. Test connectivity
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -qO- http://webapp.webapp.svc.cluster.local

# 11. Scale deployment
kubectl scale deployment webapp --replicas=5

# 12. Update image
kubectl set image deployment/webapp webapp=nginx:1.22

# 13. Check rollout
kubectl rollout status deployment/webapp
kubectl rollout history deployment/webapp

# 14. Port forward for testing
kubectl port-forward service/webapp 8080:80 &

# 15. Test locally
curl http://localhost:8080

# 16. View logs
kubectl logs -l app=webapp --tail=50

# 17. Cleanup
kubectl delete namespace webapp
```

### Troubleshooting Workflow
```bash
# 1. Check cluster status
kubectl cluster-info
kubectl get nodes
kubectl get componentstatuses

# 2. Check problematic pod
kubectl get pods
kubectl describe pod problematic-pod

# 3. Check logs
kubectl logs problematic-pod
kubectl logs problematic-pod --previous

# 4. Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# 5. Check resource usage
kubectl top nodes
kubectl top pods

# 6. Debug with temporary pod
kubectl run debug --image=busybox --rm -it --restart=Never -- /bin/sh

# 7. Network debugging
kubectl run netshoot --image=nicolaka/netshoot --rm -it --restart=Never -- /bin/bash

# 8. Check service endpoints
kubectl get endpoints
kubectl describe service problematic-service

# 9. Port forward for direct access
kubectl port-forward problematic-pod 8080:80

# 10. Execute commands in pod
kubectl exec -it problematic-pod -- /bin/bash
kubectl exec problematic-pod -- ps aux
kubectl exec problematic-pod -- netstat -tulpn
```

### Batch Operations
```bash
# Delete all pods with specific label
kubectl delete pods -l app=old-app

# Get all resources with specific label
kubectl get all -l environment=staging

# Apply multiple files
kubectl apply -f deployment.yaml -f service.yaml -f ingress.yaml

# Delete multiple resource types
kubectl delete deployment,service,ingress webapp

# Scale multiple deployments
kubectl scale deployment webapp api-server --replicas=3

# Update multiple deployments
kubectl set image deployment/webapp deployment/api-server webapp=webapp:v2 api-server=api:v2

# Get resources across all namespaces
kubectl get pods --all-namespaces -o wide

# Delete all resources in namespace
kubectl delete all --all -n staging
```

---

**Next Steps**: Proceed to Task-k8s-07 for advanced Kubernetes security, RBAC, and monitoring concepts.
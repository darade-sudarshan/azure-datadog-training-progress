# Task-k8s-01: Kubernetes Installation and Setup

## Overview
This task covers Kubernetes installation and setup using different methods: Minikube for local development, kubeadm for on-premises clusters, Azure Kubernetes Service (AKS), and Amazon Elastic Kubernetes Service (EKS).

## What is Kubernetes?

Kubernetes (K8s) is an open-source container orchestration platform that automates deployment, scaling, and management of containerized applications.

### Key Components
- **Master Node**: Control plane components (API server, etcd, scheduler, controller manager)
- **Worker Nodes**: Run application workloads (kubelet, kube-proxy, container runtime)
- **Pods**: Smallest deployable units containing one or more containers
- **Services**: Network abstraction for accessing pods
- **Deployments**: Manage replica sets and rolling updates

## Part 1: Minikube Installation and Setup

### Prerequisites
- 2 CPUs or more
- 2GB of free memory
- 20GB of free disk space
- Internet connection
- Container or virtual machine manager (Docker, VirtualBox, etc.)

### Install Minikube on Linux

#### Method 1: Binary Installation
```bash
# Download and install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Verify installation
minikube version
```

#### Method 2: Package Manager
```bash
# Ubuntu/Debian
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y minikube

# CentOS/RHEL/Fedora
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
sudo rpm -Uvh minikube-latest.x86_64.rpm
```

### Install Minikube on Windows

#### Method 1: Chocolatey
```powershell
# Install via Chocolatey
choco install minikube

# Verify installation
minikube version
```

#### Method 2: Direct Download
```powershell
# Download installer
Invoke-WebRequest -Uri "https://github.com/kubernetes/minikube/releases/latest/download/minikube-installer.exe" -OutFile "minikube-installer.exe"

# Run installer
.\minikube-installer.exe
```

### Install Minikube on macOS

#### Method 1: Homebrew
```bash
# Install via Homebrew
brew install minikube

# Verify installation
minikube version
```

#### Method 2: Binary Installation
```bash
# Download and install
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64
sudo install minikube-darwin-amd64 /usr/local/bin/minikube
```

### Install kubectl

#### Linux
```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify installation
kubectl version --client
```

#### Windows
```powershell
# Install via Chocolatey
choco install kubernetes-cli

# Or download directly
curl.exe -LO "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe"
```

#### macOS
```bash
# Install via Homebrew
brew install kubectl

# Or download directly
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

### Start Minikube Cluster

#### Basic Startup
```bash
# Start Minikube with default settings
minikube start

# Start with specific driver
minikube start --driver=docker
minikube start --driver=virtualbox

# Start with resource allocation
minikube start --cpus=4 --memory=8192 --disk-size=50g

# Start with specific Kubernetes version
minikube start --kubernetes-version=v1.28.0
```

#### Advanced Configuration
```bash
# Start with multiple nodes
minikube start --nodes=3

# Start with specific container runtime
minikube start --container-runtime=containerd

# Start with addons
minikube start --addons=dashboard,ingress,metrics-server
```

### Minikube Management Commands

#### Cluster Operations
```bash
# Check cluster status
minikube status

# Stop cluster
minikube stop

# Delete cluster
minikube delete

# Pause cluster
minikube pause

# Unpause cluster
minikube unpause

# Get cluster IP
minikube ip

# SSH into cluster
minikube ssh
```

#### Addons Management
```bash
# List available addons
minikube addons list

# Enable addon
minikube addons enable dashboard
minikube addons enable ingress
minikube addons enable metrics-server

# Disable addon
minikube addons disable dashboard

# Open dashboard
minikube dashboard
```

### Verify Minikube Installation
```bash
# Check cluster info
kubectl cluster-info

# Get nodes
kubectl get nodes

# Get system pods
kubectl get pods -n kube-system

# Create test deployment
kubectl create deployment hello-minikube --image=k8s.gcr.io/echoserver:1.4
kubectl expose deployment hello-minikube --type=NodePort --port=8080

# Access service
minikube service hello-minikube --url
```

## Part 2: Kubernetes Installation with kubeadm

### Prerequisites
- Ubuntu 18.04+ / CentOS 7+ / RHEL 7+
- 2 GB or more of RAM per machine
- 2 CPUs or more
- Full network connectivity between all machines
- Unique hostname, MAC address, and product_uuid for every node
- Swap disabled

### Prepare All Nodes

#### Disable Swap
```bash
# Disable swap temporarily
sudo swapoff -a

# Disable swap permanently
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

#### Configure Network
```bash
# Load br_netfilter module
sudo modprobe br_netfilter

# Configure sysctl
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system
```

#### Install Container Runtime (containerd)
```bash
# Install containerd
sudo apt-get update
sudo apt-get install -y containerd

# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd
```

### Install kubeadm, kubelet, and kubectl

#### Ubuntu/Debian
```bash
# Update package index
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# Add Kubernetes signing key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install Kubernetes components
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Enable kubelet
sudo systemctl enable kubelet
```

#### CentOS/RHEL/Fedora
```bash
# Add Kubernetes repository
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

# Set SELinux to permissive mode
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Install Kubernetes components
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# Enable kubelet
sudo systemctl enable kubelet
```

### Initialize Master Node

#### Initialize Cluster
```bash
# Initialize kubeadm (run on master node only)
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Configure kubectl for regular user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

#### Install Pod Network (Flannel)
```bash
# Apply Flannel CNI
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Verify pods are running
kubectl get pods -n kube-system
```

#### Alternative: Install Calico CNI
```bash
# Install Calico
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml
```

### Join Worker Nodes

#### Get Join Command
```bash
# On master node, get join command
kubeadm token create --print-join-command
```

#### Join Worker Nodes
```bash
# Run on each worker node (replace with actual command from above)
sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

### Verify Cluster
```bash
# Check nodes
kubectl get nodes

# Check system pods
kubectl get pods -n kube-system

# Check cluster info
kubectl cluster-info
```

## Part 3: Azure Kubernetes Service (AKS)

### Prerequisites
- Azure CLI installed and configured
- Azure subscription with appropriate permissions
- Resource group created

### Install Azure CLI

#### Linux
```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login to Azure
az login
```

#### Windows
```powershell
# Install via Chocolatey
choco install azure-cli

# Or download MSI installer from Microsoft
```

#### macOS
```bash
# Install via Homebrew
brew install azure-cli
```

### Create AKS Cluster

#### Basic AKS Cluster
```bash
# Set variables
RESOURCE_GROUP="sa1_test_eic_SudarshanDarade"
CLUSTER_NAME="aks-cluster-demo"
LOCATION="southeastasia"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create AKS cluster
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 3 \
  --node-vm-size Standard_D2s_v3 \
  --enable-addons monitoring \
  --generate-ssh-keys

# Get credentials
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
```

#### Advanced AKS Cluster
```bash
# Create AKS with advanced features
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 3 \
  --node-vm-size Standard_D4s_v3 \
  --kubernetes-version 1.28.0 \
  --enable-addons monitoring,azure-policy,azure-keyvault-secrets-provider \
  --enable-managed-identity \
  --enable-cluster-autoscaler \
  --min-count 1 \
  --max-count 10 \
  --network-plugin azure \
  --network-policy azure \
  --service-cidr 10.0.0.0/16 \
  --dns-service-ip 10.0.0.10 \
  --docker-bridge-address 172.17.0.1/16 \
  --generate-ssh-keys
```

#### Create Node Pools
```bash
# Add Windows node pool
az aks nodepool add \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name winnp \
  --node-count 2 \
  --node-vm-size Standard_D2s_v3 \
  --os-type Windows

# Add spot instance node pool
az aks nodepool add \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name spotnp \
  --node-count 2 \
  --node-vm-size Standard_D2s_v3 \
  --priority Spot \
  --eviction-policy Delete \
  --spot-max-price -1
```

### AKS Management Commands

#### Cluster Operations
```bash
# List AKS clusters
az aks list --output table

# Show cluster details
az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME

# Start stopped cluster
az aks start --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME

# Stop cluster
az aks stop --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME

# Upgrade cluster
az aks upgrade --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --kubernetes-version 1.28.0

# Scale cluster
az aks scale --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --node-count 5
```

#### Node Pool Management
```bash
# List node pools
az aks nodepool list --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME

# Scale node pool
az aks nodepool scale \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name nodepool1 \
  --node-count 5

# Delete node pool
az aks nodepool delete \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name spotnp
```

### Verify AKS Cluster
```bash
# Check cluster connection
kubectl cluster-info

# Get nodes
kubectl get nodes

# Get system pods
kubectl get pods -n kube-system

# Create test deployment
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Get service external IP
kubectl get service nginx
```

## Part 4: Amazon Elastic Kubernetes Service (EKS)

### Prerequisites
- AWS CLI installed and configured
- eksctl tool installed
- kubectl installed
- AWS IAM permissions for EKS

### Install AWS CLI

#### Linux
```bash
# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS CLI
aws configure
```

#### Windows
```powershell
# Download and install AWS CLI MSI
# Or install via Chocolatey
choco install awscli

# Configure AWS CLI
aws configure
```

#### macOS
```bash
# Install via Homebrew
brew install awscli

# Configure AWS CLI
aws configure
```

### Install eksctl

#### Linux
```bash
# Download and install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Verify installation
eksctl version
```

#### Windows
```powershell
# Install via Chocolatey
choco install eksctl

# Or download from GitHub releases
```

#### macOS
```bash
# Install via Homebrew
brew tap weaveworks/tap
brew install weaveworks/tap/eksctl
```

### Create EKS Cluster

#### Basic EKS Cluster
```bash
# Create basic EKS cluster
eksctl create cluster \
  --name eks-cluster-01 \
  --region us-west-2 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 4 \
  --managed
```

#### Advanced EKS Cluster
```bash
# Create advanced EKS cluster with configuration file
cat <<EOF > eks-cluster.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eks-advanced-cluster
  region: us-west-2
  version: "1.28"

managedNodeGroups:
  - name: standard-workers
    instanceType: t3.medium
    minSize: 1
    maxSize: 10
    desiredCapacity: 3
    volumeSize: 20
    ssh:
      allow: true
    labels:
      role: worker
    tags:
      nodegroup-role: worker

  - name: spot-workers
    instanceTypes: ["t3.medium", "t3.large"]
    spot: true
    minSize: 0
    maxSize: 5
    desiredCapacity: 2
    labels:
      lifecycle: Ec2Spot
      role: worker

addons:
  - name: vpc-cni
  - name: coredns
  - name: kube-proxy
  - name: aws-ebs-csi-driver

cloudWatch:
  clusterLogging:
    enable: ["api", "audit", "authenticator", "controllerManager", "scheduler"]
EOF

# Create cluster from config file
eksctl create cluster -f eks-cluster.yaml
```

#### Create Fargate Profile
```bash
# Create Fargate profile
eksctl create fargateprofile \
  --cluster eks-cluster-01 \
  --region us-west-2 \
  --name fp-default \
  --namespace default \
  --namespace kube-system
```

### EKS Management Commands

#### Cluster Operations
```bash
# List EKS clusters
eksctl get cluster

# Get cluster info
eksctl get cluster --name eks-cluster-01 --region us-west-2

# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name eks-cluster-01

# Scale nodegroup
eksctl scale nodegroup \
  --cluster eks-cluster-01 \
  --region us-west-2 \
  --name standard-workers \
  --nodes 5

# Upgrade cluster
eksctl upgrade cluster --name eks-cluster-01 --region us-west-2
```

#### Node Group Management
```bash
# List node groups
eksctl get nodegroup --cluster eks-cluster-01 --region us-west-2

# Create new node group
eksctl create nodegroup \
  --cluster eks-cluster-01 \
  --region us-west-2 \
  --name new-workers \
  --node-type t3.large \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 4

# Delete node group
eksctl delete nodegroup \
  --cluster eks-cluster-01 \
  --region us-west-2 \
  --name spot-workers
```

### Install AWS Load Balancer Controller
```bash
# Create IAM OIDC provider
eksctl utils associate-iam-oidc-provider \
  --region us-west-2 \
  --cluster eks-cluster-01 \
  --approve

# Create IAM service account
eksctl create iamserviceaccount \
  --cluster eks-cluster-01 \
  --region us-west-2 \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess \
  --override-existing-serviceaccounts \
  --approve

# Install AWS Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=eks-cluster-01 \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

### Verify EKS Cluster
```bash
# Check cluster connection
kubectl cluster-info

# Get nodes
kubectl get nodes

# Get system pods
kubectl get pods -n kube-system

# Create test deployment
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Get service external IP
kubectl get service nginx
```

## Cluster Cleanup

### Minikube Cleanup
```bash
# Stop and delete Minikube cluster
minikube stop
minikube delete --all
```

### kubeadm Cleanup
```bash
# On worker nodes
sudo kubeadm reset
sudo rm -rf /etc/cni/net.d
sudo rm -rf $HOME/.kube/config

# On master node
sudo kubeadm reset
sudo rm -rf /etc/cni/net.d
sudo rm -rf $HOME/.kube/config
```

### AKS Cleanup
```bash
# Delete AKS cluster
az aks delete --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --yes --no-wait

# Delete resource group
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

### EKS Cleanup
```bash
# Delete EKS cluster
eksctl delete cluster --name eks-cluster-01 --region us-west-2
```

## Verification Checklist

### Minikube
- ✅ Minikube installed and cluster started
- ✅ kubectl configured and working
- ✅ Dashboard accessible
- ✅ Sample application deployed and accessible

### kubeadm
- ✅ All nodes joined cluster successfully
- ✅ Pod network (CNI) installed and working
- ✅ System pods running in kube-system namespace
- ✅ Sample application deployed across nodes

### AKS
- ✅ AKS cluster created and accessible
- ✅ Node pools configured correctly
- ✅ Azure integrations working (monitoring, networking)
- ✅ Sample application with LoadBalancer service working

### EKS
- ✅ EKS cluster created and accessible
- ✅ Node groups or Fargate profiles configured
- ✅ AWS integrations working (IAM, VPC, ELB)
- ✅ Sample application with LoadBalancer service working

---

**Next Steps**: Proceed to Task-k8s-02 for Kubernetes workload deployment, services, and application management.
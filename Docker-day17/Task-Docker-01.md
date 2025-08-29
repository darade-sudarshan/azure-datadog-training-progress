# Task-Docker-01: Docker Overview and Installation Guide

## Overview
This task provides comprehensive information about Docker containerization technology, its architecture, components, and installation procedures across different platforms.

## What is Docker?

Docker is a containerization platform that enables developers to package applications and their dependencies into lightweight, portable containers. These containers can run consistently across different environments, from development laptops to production servers.

### Key Benefits
- **Portability**: Run anywhere - development, testing, production
- **Consistency**: Same environment across all stages
- **Efficiency**: Lightweight compared to virtual machines
- **Scalability**: Easy horizontal scaling
- **Isolation**: Applications run in isolated environments
- **Speed**: Fast startup and deployment times

## Docker Architecture

### Core Components

#### 1. Docker Engine
- **Docker Daemon (dockerd)**: Background service managing containers
- **Docker CLI**: Command-line interface for interacting with Docker
- **REST API**: Interface for programmatic access

#### 2. Docker Objects
- **Images**: Read-only templates for creating containers
- **Containers**: Runnable instances of images
- **Networks**: Enable communication between containers
- **Volumes**: Persistent data storage
- **Services**: Define how containers run in production

#### 3. Docker Registry
- **Docker Hub**: Public registry for sharing images
- **Private Registries**: Enterprise-grade image storage
- **Local Registry**: On-premises image storage

### Docker vs Virtual Machines

| Feature | Docker Containers | Virtual Machines |
|---------|------------------|------------------|
| **Resource Usage** | Lightweight, shares OS kernel | Heavy, full OS per VM |
| **Startup Time** | Seconds | Minutes |
| **Isolation** | Process-level | Hardware-level |
| **Portability** | High | Medium |
| **Performance** | Near-native | Overhead from hypervisor |
| **Storage** | MBs | GBs |

## Docker Installation Methods

### Supported Platforms
- **Linux**: Ubuntu, CentOS, RHEL, Debian, Fedora, Amazon Linux
- **Windows**: Windows 10/11 Pro, Enterprise, Education (with WSL2)
- **macOS**: macOS 10.15+ (Intel and Apple Silicon)

### Installation Scripts
Automated installation scripts are available for each platform:

#### Linux Installation
```bash
# Download and run the Linux installation script
wget https://raw.githubusercontent.com/your-repo/docker-install-linux.sh
chmod +x docker-install-linux.sh
./docker-install-linux.sh
```

#### Windows Installation
```powershell
# Download and run the Windows installation script (as Administrator)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/your-repo/docker-install-windows.ps1" -OutFile "docker-install-windows.ps1"
.\docker-install-windows.ps1
```

#### macOS Installation
```bash
# Download and run the macOS installation script
curl -fsSL https://raw.githubusercontent.com/your-repo/docker-install-macos.sh -o docker-install-macos.sh
chmod +x docker-install-macos.sh
./docker-install-macos.sh
```

### Quick Installation Commands

#### Ubuntu/Debian
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

#### CentOS/RHEL
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

#### Windows (PowerShell as Admin)
```powershell
winget install Docker.DockerDesktop
```

#### macOS
```bash
brew install --cask docker
```gure Docker Desktop
configure_docker() {
    print_status "Configuring Docker Desktop..."
    
    # Create Docker Desktop settings directory
    mkdir -p ~/Library/Group\ Containers/group.com.docker/settings
    
    # Create basic settings file
    cat > ~/Library/Group\ Containers/group.com.docker/settings/settings.json << EOF
{
    "memoryMiB": 4096,
    "cpus": 2,
    "diskSizeMiB": 61440,
    "useVirtualizationFramework": true,
    "useVirtualizationFrameworkVirtioFS": true,
    "useRosetta": false
}
EOF
}

# Start Docker Desktop
start_docker() {
    print_status "Starting Docker Desktop..."
    open -a Docker
    
    # Wait for Docker to start
    print_status "Waiting for Docker to start..."
    while ! docker info >/dev/null 2>&1; do
        sleep 5
        echo -n "."
    done
    echo ""
}

# Verify installation
verify_installation() {
    print_status "Verifying Docker installation..."
    
    # Check Docker version
    docker --version
    
    # Check Docker Compose version
    docker compose version
    
    # Run hello-world container
    if docker run hello-world >/dev/null 2>&1; then
        print_status "Docker installation successful!"
    else
        print_error "Docker installation verification failed"
        exit 1
    fi
}

# Main installation function
main() {
    print_status "Starting Docker installation on macOS..."
    
    detect_system
    
    # Try Homebrew installation first
    if check_homebrew || { print_warning "Installing Homebrew first..."; install_homebrew; }; then
        install_docker_homebrew
    else
        print_warning "Homebrew installation failed, trying manual installation..."
        install_docker_manual
    fi
    
    configure_docker
    start_docker
    verify_installation
    
    print_status "Docker installation completed successfully!"
}

# Run main function
main "$@"
```

## Docker Components Deep Dive

### 1. Docker Images
Images are read-only templates used to create containers. They contain:
- **Base OS**: Minimal operating system layer
- **Application Code**: Your application files
- **Dependencies**: Required libraries and packages
- **Configuration**: Environment variables and settings

#### Image Layers
- Images are built in layers using Union File System
- Each instruction in Dockerfile creates a new layer
- Layers are cached and reused for efficiency
- Only changed layers need to be rebuilt

### 2. Docker Containers
Containers are running instances of images with:
- **Writable Layer**: Added on top of image layers
- **Process Isolation**: Separate process namespace
- **Network Interface**: Virtual network interface
- **File System**: Isolated file system view

### 3. Docker Networks
Docker provides several network drivers:
- **Bridge**: Default network for standalone containers
- **Host**: Remove network isolation, use host networking
- **Overlay**: Multi-host networking for swarm services
- **Macvlan**: Assign MAC address to containers
- **None**: Disable networking

### 4. Docker Volumes
Persistent data storage options:
- **Named Volumes**: Managed by Docker
- **Bind Mounts**: Host directory mounted into container
- **tmpfs Mounts**: Temporary file system in memory

## Docker Workflow

### Development Workflow
1. **Write Dockerfile**: Define application environment
2. **Build Image**: Create image from Dockerfile
3. **Run Container**: Start container from image
4. **Test Application**: Verify functionality
5. **Push to Registry**: Share image with team
6. **Deploy**: Run in production environment

### Basic Docker Commands

#### Image Management
```bash
# Build image from Dockerfile
docker build -t myapp:latest .

# List images
docker images

# Pull image from registry
docker pull nginx:latest

# Remove image
docker rmi myapp:latest

# Tag image
docker tag myapp:latest myapp:v1.0
```

#### Container Management
```bash
# Run container
docker run -d --name mycontainer nginx

# List running containers
docker ps

# List all containers
docker ps -a

# Stop container
docker stop mycontainer

# Start container
docker start mycontainer

# Remove container
docker rm mycontainer

# Execute command in running container
docker exec -it mycontainer bash
```

#### Network Management
```bash
# Create network
docker network create mynetwork

# List networks
docker network ls

# Connect container to network
docker network connect mynetwork mycontainer

# Inspect network
docker network inspect mynetwork
```

#### Volume Management
```bash
# Create volume
docker volume create myvolume

# List volumes
docker volume ls

# Mount volume to container
docker run -v myvolume:/data nginx

# Remove volume
docker volume rm myvolume
```

## Post-Installation Configuration

### Docker Daemon Configuration
```bash
# Create daemon configuration file
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "storage-driver": "overlay2",
    "dns": ["8.8.8.8", "8.8.4.4"]
}
EOF

# Restart Docker to apply configuration
sudo systemctl restart docker
```

### User Configuration
```bash
# Add current user to docker group (Linux only)
sudo usermod -aG docker $USER

# Create Docker configuration directory
mkdir -p ~/.docker

# Configure Docker CLI
cat > ~/.docker/config.json <<EOF
{
    "auths": {},
    "experimental": "enabled"
}
EOF
```

## Docker Compose Installation

Docker Compose is a tool for defining and running multi-container applications using YAML files.

### Installation Methods

#### Linux Installation
```bash
# Method 1: Download binary
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d'"' -f4)
sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Method 2: Install via pip
pip3 install docker-compose

# Method 3: Install via package manager (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install docker-compose-plugin

# Verify installation
docker compose version
```

#### Windows Installation
```powershell
# Docker Compose is included with Docker Desktop
# Verify installation
docker compose version

# Alternative: Install via Chocolatey
choco install docker-compose
```

#### macOS Installation
```bash
# Docker Compose is included with Docker Desktop
# Verify installation
docker compose version

# Alternative: Install via Homebrew
brew install docker-compose
```

### Key Features
- **Multi-container orchestration**
- **Service dependencies**
- **Environment management**
- **Volume and network management**
- **Scaling services**

### Basic Compose Commands
```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs

# Scale services
docker compose up --scale web=3

# Build services
docker compose build
```

## Docker Swarm Installation and Setup

Docker Swarm is Docker's native clustering and orchestration solution.

### Prerequisites
- Docker Engine installed on all nodes
- Network connectivity between nodes
- Open ports: 2377 (cluster management), 7946 (node communication), 4789 (overlay network)

### Swarm Initialization

#### Initialize Swarm Manager
```bash
# Initialize swarm on manager node
docker swarm init

# Initialize with specific advertise address
docker swarm init --advertise-addr <MANAGER-IP>

# Example
docker swarm init --advertise-addr 192.168.1.100
```

#### Get Join Tokens
```bash
# Get worker join token
docker swarm join-token worker

# Get manager join token
docker swarm join-token manager

# Rotate join tokens
docker swarm join-token --rotate worker
```

#### Join Worker Nodes
```bash
# On worker nodes, run the command from join-token output
docker swarm join --token SWMTKN-1-xxx <MANAGER-IP>:2377
```

#### Join Manager Nodes
```bash
# On additional manager nodes
docker swarm join --token SWMTKN-1-xxx <MANAGER-IP>:2377
```

### Swarm Management Commands
```bash
# List nodes
docker node ls

# Inspect node
docker node inspect <NODE-ID>

# Promote worker to manager
docker node promote <NODE-ID>

# Demote manager to worker
docker node demote <NODE-ID>

# Remove node from swarm
docker node rm <NODE-ID>

# Leave swarm (run on node to be removed)
docker swarm leave

# Force leave (on manager)
docker swarm leave --force
```

### Network Configuration
```bash
# Configure firewall (Ubuntu/Debian)
sudo ufw allow 2377/tcp
sudo ufw allow 7946/tcp
sudo ufw allow 7946/udp
sudo ufw allow 4789/udp

# Configure firewall (CentOS/RHEL)
sudo firewall-cmd --permanent --add-port=2377/tcp
sudo firewall-cmd --permanent --add-port=7946/tcp
sudo firewall-cmd --permanent --add-port=7946/udp
sudo firewall-cmd --permanent --add-port=4789/udp
sudo firewall-cmd --reload
```

### Basic Service Deployment
```bash
# Create a service
docker service create --name web --replicas 3 --publish 80:80 nginx

# List services
docker service ls

# Scale service
docker service scale web=5

# Update service
docker service update --image nginx:alpine web

# Remove service
docker service rm web
```

## Verification and Testing

### Installation Verification
```bash
# Check Docker version
docker --version
docker version

# Check Docker info
docker info

# Test with hello-world
docker run hello-world

# Check Docker Compose
docker compose version

# Check Swarm status (if initialized)
docker info | grep Swarm
```

### Testing Script
Use the provided `docker-test.sh` script to verify your installation:
```bash
# Make script executable
chmod +x docker-test.sh

# Run tests
./docker-test.sh
```

### Swarm Testing
```bash
# Test swarm functionality
docker service create --name test-service --replicas 2 alpine ping docker.com
docker service ls
docker service ps test-service
docker service rm test-service
```

## Troubleshooting Common Issues

### Linux Troubleshooting
```bash
# Check Docker service status
sudo systemctl status docker

# Check Docker logs
sudo journalctl -u docker.service

# Fix permission issues
sudo chmod 666 /var/run/docker.sock

# Restart Docker service
sudo systemctl restart docker

# Check disk space
df -h
docker system df
docker system prune -f
```

### Windows Troubleshooting
```powershell
# Check WSL2 status
wsl --list --verbose

# Restart Docker Desktop
Stop-Process -Name "Docker Desktop" -Force
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

# Check Hyper-V status
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
```

### macOS Troubleshooting
```bash
# Restart Docker Desktop
killall Docker
open -a Docker

# Check Docker Desktop logs
tail -f ~/Library/Containers/com.docker.docker/Data/log/vm/dockerd.log
```

## Security Best Practices

### Container Security
- **Use official base images** from trusted sources
- **Keep images updated** with latest security patches
- **Run as non-root user** inside containers
- **Limit container capabilities** using --cap-drop
- **Use read-only file systems** when possible
- **Scan images for vulnerabilities** before deployment

### Docker Content Trust
```bash
# Enable content trust
export DOCKER_CONTENT_TRUST=1

# Add to shell profile
echo 'export DOCKER_CONTENT_TRUST=1' >> ~/.bashrc
```

### Registry Authentication
```bash
# Login to Docker Hub
docker login

# Login to private registry
docker login myregistry.com
```

## Performance Optimization

### Docker Daemon Optimization
```json
{
    "storage-driver": "overlay2",
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "max-concurrent-downloads": 10,
    "max-concurrent-uploads": 5
}
```

### Container Resource Limits
```bash
# Set memory limit
docker run -m 512m nginx

# Set CPU limit
docker run --cpus="1.5" nginx

# Set both memory and CPU
docker run -m 1g --cpus="2" nginx
```

### Image Optimization
- **Use multi-stage builds** to reduce image size
- **Minimize layers** by combining RUN commands
- **Use .dockerignore** to exclude unnecessary files
- **Choose appropriate base images** (alpine for smaller size)
- **Clean up package caches** in the same layer

## Docker Best Practices

### Dockerfile Best Practices
1. **Use specific tags** instead of 'latest'
2. **Order instructions by change frequency** (least to most)
3. **Use COPY instead of ADD** unless you need ADD's features
4. **Set appropriate USER** for security
5. **Use HEALTHCHECK** for container health monitoring
6. **Minimize the number of layers**
7. **Use .dockerignore** to exclude build context

### Container Management
1. **Use meaningful names** for containers and images
2. **Implement proper logging** strategies
3. **Monitor resource usage** regularly
4. **Use orchestration tools** for production
5. **Implement backup strategies** for persistent data
6. **Regular security updates** and vulnerability scanning

### Development Workflow
1. **Use Docker Compose** for multi-container applications
2. **Implement CI/CD pipelines** with Docker
3. **Use version control** for Dockerfiles
4. **Test images** before deployment
5. **Document container requirements** and usage

## Docker Ecosystem Tools

### Container Orchestration
- **Docker Swarm**: Native Docker clustering
- **Kubernetes**: Advanced container orchestration
- **Amazon ECS**: AWS container service
- **Azure Container Instances**: Serverless containers

### Monitoring and Logging
- **Docker Stats**: Built-in resource monitoring
- **Prometheus**: Metrics collection
- **Grafana**: Metrics visualization
- **ELK Stack**: Centralized logging
- **Fluentd**: Log forwarding

### Security Tools
- **Docker Bench**: Security best practices checker
- **Clair**: Vulnerability scanner
- **Twistlock**: Container security platform
- **Aqua Security**: Runtime protection

## Verification Checklist

### Docker Engine
- ✅ Docker Engine installed and running
- ✅ User added to docker group (Linux)
- ✅ Docker daemon configured optimally
- ✅ Basic container operations tested
- ✅ Network and volume operations verified

### Docker Compose
- ✅ Docker Compose installed and functional
- ✅ Multi-container applications deployable
- ✅ Compose commands working correctly
- ✅ YAML syntax validation passed

### Docker Swarm
- ✅ Swarm mode initialized successfully
- ✅ Worker nodes joined to cluster
- ✅ Manager nodes configured (if applicable)
- ✅ Network ports opened and configured
- ✅ Basic service deployment tested
- ✅ Service scaling and updates working

### General
- ✅ Security configurations applied
- ✅ Performance optimizations implemented
- ✅ Troubleshooting procedures documented
- ✅ Installation scripts tested and working

---

**Next Steps**: Proceed to Task-Docker-02 for container creation, management, and Docker Compose orchestration.
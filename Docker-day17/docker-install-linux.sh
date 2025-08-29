#!/bin/bash
# docker-install-linux.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    else
        print_error "Cannot detect OS"
        exit 1
    fi
    print_status "Detected OS: $OS $VER"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_warning "Running as root. Consider running as regular user."
        SUDO=""
    else
        SUDO="sudo"
    fi
}

# Install Docker on Ubuntu/Debian
install_ubuntu_debian() {
    print_status "Installing Docker on Ubuntu/Debian..."
    
    # Update package index
    $SUDO apt-get update
    
    # Install prerequisites
    $SUDO apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker's GPG key
    $SUDO mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Add repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker
    $SUDO apt-get update
    $SUDO apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

# Install Docker on CentOS/RHEL/Fedora
install_centos_rhel() {
    print_status "Installing Docker on CentOS/RHEL/Fedora..."
    
    # Install prerequisites
    $SUDO yum install -y yum-utils device-mapper-persistent-data lvm2
    
    # Add Docker repository
    $SUDO yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    
    # Install Docker
    $SUDO yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

# Install Docker on Amazon Linux
install_amazon_linux() {
    print_status "Installing Docker on Amazon Linux..."
    
    # Update system
    $SUDO yum update -y
    
    # Install Docker
    $SUDO yum install -y docker
}

# Configure Docker
configure_docker() {
    print_status "Configuring Docker..."
    
    # Start and enable Docker
    $SUDO systemctl start docker
    $SUDO systemctl enable docker
    
    # Add current user to docker group
    if [[ $EUID -ne 0 ]]; then
        $SUDO usermod -aG docker $USER
        print_warning "Please log out and log back in for group changes to take effect"
    fi
    
    # Create Docker daemon configuration
    $SUDO mkdir -p /etc/docker
    cat <<EOF | $SUDO tee /etc/docker/daemon.json
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "storage-driver": "overlay2"
}
EOF
    
    # Restart Docker to apply configuration
    $SUDO systemctl restart docker
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
    print_status "Starting Docker installation..."
    
    detect_os
    check_root
    
    case "$OS" in
        "Ubuntu"|"Debian"*)
            install_ubuntu_debian
            ;;
        "CentOS"*|"Red Hat"*|"Fedora"*)
            install_centos_rhel
            ;;
        "Amazon Linux"*)
            install_amazon_linux
            ;;
        *)
            print_error "Unsupported OS: $OS"
            exit 1
            ;;
    esac
    
    configure_docker
    verify_installation
    
    print_status "Docker installation completed successfully!"
    print_warning "Please log out and log back in to use Docker without sudo"
}

# Run main function
main "$@"
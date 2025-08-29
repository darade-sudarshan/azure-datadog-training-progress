#!/bin/bash
# docker-compose-install.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    print_status "Docker is installed"
}

# Detect OS
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$NAME
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
    else
        print_error "Cannot detect OS"
        exit 1
    fi
    print_status "Detected OS: $OS"
}

# Install Docker Compose via binary download
install_compose_binary() {
    print_status "Installing Docker Compose via binary download..."
    
    # Get latest version
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d'"' -f4)
    print_status "Latest Docker Compose version: $COMPOSE_VERSION"
    
    # Download binary
    sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    
    # Make executable
    sudo chmod +x /usr/local/bin/docker-compose
    
    # Create symlink
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
}

# Install Docker Compose via package manager
install_compose_package() {
    case "$OS" in
        "Ubuntu"|"Debian"*)
            print_status "Installing Docker Compose via apt..."
            sudo apt-get update
            sudo apt-get install -y docker-compose-plugin
            ;;
        "CentOS"*|"Red Hat"*|"Fedora"*)
            print_status "Installing Docker Compose via yum/dnf..."
            if command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y docker-compose-plugin
            else
                sudo yum install -y docker-compose-plugin
            fi
            ;;
        *)
            print_warning "Package manager installation not supported for $OS, using binary method"
            install_compose_binary
            ;;
    esac
}

# Install Docker Compose via pip
install_compose_pip() {
    print_status "Installing Docker Compose via pip..."
    
    # Check if pip is available
    if command -v pip3 >/dev/null 2>&1; then
        pip3 install --user docker-compose
    elif command -v pip >/dev/null 2>&1; then
        pip install --user docker-compose
    else
        print_error "pip is not available"
        return 1
    fi
}

# Verify installation
verify_installation() {
    print_status "Verifying Docker Compose installation..."
    
    if command -v docker-compose >/dev/null 2>&1; then
        COMPOSE_VERSION=$(docker-compose --version)
        print_status "Docker Compose installed: $COMPOSE_VERSION"
    elif docker compose version >/dev/null 2>&1; then
        COMPOSE_VERSION=$(docker compose version)
        print_status "Docker Compose plugin installed: $COMPOSE_VERSION"
    else
        print_error "Docker Compose installation failed"
        exit 1
    fi
    
    # Test with simple compose file
    cat > /tmp/test-compose.yml <<EOF
version: '3.8'
services:
  test:
    image: hello-world
EOF
    
    cd /tmp
    if docker compose -f test-compose.yml config >/dev/null 2>&1; then
        print_status "Docker Compose configuration test passed"
    elif docker-compose -f test-compose.yml config >/dev/null 2>&1; then
        print_status "Docker Compose configuration test passed"
    else
        print_error "Docker Compose configuration test failed"
    fi
    
    rm -f /tmp/test-compose.yml
}

# Main installation function
main() {
    print_status "Starting Docker Compose installation..."
    
    check_docker
    detect_os
    
    # Try package manager first, then binary
    if ! install_compose_package; then
        print_warning "Package installation failed, trying binary installation..."
        install_compose_binary
    fi
    
    verify_installation
    
    print_status "Docker Compose installation completed successfully!"
    print_status "You can now use 'docker compose' or 'docker-compose' commands"
}

# Run main function
main "$@"
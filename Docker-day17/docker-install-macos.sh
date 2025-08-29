#!/bin/bash
# docker-install-macos.sh

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

# Detect macOS version and architecture
detect_system() {
    MACOS_VERSION=$(sw_vers -productVersion)
    ARCH=$(uname -m)
    
    print_status "macOS Version: $MACOS_VERSION"
    print_status "Architecture: $ARCH"
    
    # Check minimum macOS version
    if [[ $(echo "$MACOS_VERSION 10.15" | awk '{print ($1 >= $2)}') -eq 0 ]]; then
        print_error "macOS 10.15 or later is required"
        exit 1
    fi
}

# Check if Homebrew is installed
check_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        print_status "Homebrew is already installed"
        return 0
    else
        print_warning "Homebrew not found"
        return 1
    fi
}

# Install Homebrew
install_homebrew() {
    print_status "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ "$ARCH" == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
}

# Install Docker Desktop via Homebrew
install_docker_homebrew() {
    print_status "Installing Docker Desktop via Homebrew..."
    brew install --cask docker
}

# Install Docker Desktop manually
install_docker_manual() {
    print_status "Installing Docker Desktop manually..."
    
    # Determine download URL based on architecture
    if [[ "$ARCH" == "arm64" ]]; then
        DOCKER_URL="https://desktop.docker.com/mac/main/arm64/Docker.dmg"
    else
        DOCKER_URL="https://desktop.docker.com/mac/main/amd64/Docker.dmg"
    fi
    
    # Download Docker Desktop
    print_status "Downloading Docker Desktop..."
    curl -L -o /tmp/Docker.dmg "$DOCKER_URL"
    
    # Mount DMG
    print_status "Mounting Docker.dmg..."
    hdiutil attach /tmp/Docker.dmg
    
    # Copy Docker to Applications
    print_status "Installing Docker Desktop..."
    cp -R "/Volumes/Docker/Docker.app" "/Applications/"
    
    # Unmount DMG
    hdiutil detach "/Volumes/Docker"
    
    # Clean up
    rm /tmp/Docker.dmg
}

# Configure Docker Desktop
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
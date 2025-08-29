#!/bin/bash
# docker-swarm-setup.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_info() {
    echo -e "${BLUE}[SETUP]${NC} $1"
}

# Check if Docker is installed and running
check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker daemon is not running. Please start Docker."
        exit 1
    fi
    
    print_status "Docker is installed and running"
}

# Get local IP address
get_local_ip() {
    # Try different methods to get local IP
    LOCAL_IP=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $7; exit}')
    
    if [[ -z "$LOCAL_IP" ]]; then
        LOCAL_IP=$(hostname -I | awk '{print $1}')
    fi
    
    if [[ -z "$LOCAL_IP" ]]; then
        LOCAL_IP="127.0.0.1"
        print_warning "Could not detect local IP, using localhost"
    fi
    
    print_status "Detected local IP: $LOCAL_IP"
}

# Configure firewall
configure_firewall() {
    print_status "Configuring firewall for Docker Swarm..."
    
    # Check if ufw is available (Ubuntu/Debian)
    if command -v ufw >/dev/null 2>&1; then
        print_info "Configuring UFW firewall..."
        sudo ufw allow 2377/tcp comment "Docker Swarm cluster management"
        sudo ufw allow 7946/tcp comment "Docker Swarm node communication TCP"
        sudo ufw allow 7946/udp comment "Docker Swarm node communication UDP"
        sudo ufw allow 4789/udp comment "Docker Swarm overlay network"
        print_status "UFW firewall configured"
    
    # Check if firewall-cmd is available (CentOS/RHEL/Fedora)
    elif command -v firewall-cmd >/dev/null 2>&1; then
        print_info "Configuring firewalld..."
        sudo firewall-cmd --permanent --add-port=2377/tcp
        sudo firewall-cmd --permanent --add-port=7946/tcp
        sudo firewall-cmd --permanent --add-port=7946/udp
        sudo firewall-cmd --permanent --add-port=4789/udp
        sudo firewall-cmd --reload
        print_status "Firewalld configured"
    
    else
        print_warning "No supported firewall found. Please manually open ports:"
        print_warning "  - 2377/tcp (cluster management)"
        print_warning "  - 7946/tcp and 7946/udp (node communication)"
        print_warning "  - 4789/udp (overlay network)"
    fi
}

# Initialize Docker Swarm
init_swarm() {
    print_status "Initializing Docker Swarm..."
    
    # Check if already in swarm mode
    if docker info 2>/dev/null | grep -q "Swarm: active"; then
        print_warning "Docker Swarm is already initialized"
        return 0
    fi
    
    # Initialize swarm
    if docker swarm init --advertise-addr "$LOCAL_IP" >/dev/null 2>&1; then
        print_status "Docker Swarm initialized successfully"
    else
        print_error "Failed to initialize Docker Swarm"
        exit 1
    fi
}

# Display join tokens
show_join_tokens() {
    print_info "Docker Swarm join tokens:"
    echo
    
    print_info "To add a worker node to this swarm, run:"
    echo -e "${BLUE}$(docker swarm join-token worker -q | sed 's/^/    /')${NC}"
    docker swarm join-token worker | grep "docker swarm join" | sed 's/^/    /'
    echo
    
    print_info "To add a manager node to this swarm, run:"
    echo -e "${BLUE}$(docker swarm join-token manager -q | sed 's/^/    /')${NC}"
    docker swarm join-token manager | grep "docker swarm join" | sed 's/^/    /'
    echo
}

# Create test service
create_test_service() {
    print_status "Creating test service to verify swarm functionality..."
    
    # Create a simple test service
    docker service create \
        --name swarm-test \
        --replicas 2 \
        --publish 8080:80 \
        nginx:alpine >/dev/null 2>&1
    
    print_status "Test service 'swarm-test' created"
    
    # Wait for service to be ready
    print_info "Waiting for service to be ready..."
    sleep 10
    
    # Show service status
    print_info "Service status:"
    docker service ls
    echo
    docker service ps swarm-test
    
    print_info "Test the service by visiting: http://$LOCAL_IP:8080"
    print_warning "Remember to remove the test service: docker service rm swarm-test"
}

# Show swarm information
show_swarm_info() {
    print_info "Docker Swarm cluster information:"
    echo
    
    print_info "Nodes in the swarm:"
    docker node ls
    echo
    
    print_info "Swarm status:"
    docker info | grep -A 10 "Swarm:"
}

# Main setup function
main() {
    print_status "Starting Docker Swarm setup..."
    echo
    
    # Parse command line arguments
    SKIP_FIREWALL=false
    CREATE_TEST=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-firewall)
                SKIP_FIREWALL=true
                shift
                ;;
            --create-test)
                CREATE_TEST=true
                shift
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --skip-firewall    Skip firewall configuration"
                echo "  --create-test      Create a test service"
                echo "  --help            Show this help message"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    check_docker
    get_local_ip
    
    if [[ "$SKIP_FIREWALL" != "true" ]]; then
        configure_firewall
    else
        print_warning "Skipping firewall configuration"
    fi
    
    init_swarm
    show_join_tokens
    show_swarm_info
    
    if [[ "$CREATE_TEST" == "true" ]]; then
        create_test_service
    fi
    
    echo
    print_status "Docker Swarm setup completed successfully!"
    print_info "Manager node is ready at: $LOCAL_IP"
    print_info "Use the join tokens above to add worker/manager nodes"
}

# Run main function
main "$@"
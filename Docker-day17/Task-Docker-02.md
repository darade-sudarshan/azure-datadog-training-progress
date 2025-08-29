# Task-Docker-02: Docker Commands with Examples and Explanations

## Overview
This task covers essential Docker commands with practical examples and detailed explanations for container management, image operations, networking, volumes, and troubleshooting.

## Docker Command Structure

### Basic Syntax
```bash
docker [OPTIONS] COMMAND [ARG...]
```

### Getting Help
```bash
# General help
docker --help

# Command-specific help
docker run --help
docker build --help

# Docker version information
docker version
docker info
```

## Image Management Commands

### 1. Pulling Images
```bash
# Pull latest version of an image
docker pull nginx
docker pull ubuntu:20.04

# Pull specific tag
docker pull redis:6.2-alpine

# Pull from specific registry
docker pull gcr.io/google-containers/busybox
```

**Explanation**: Downloads images from Docker registries to local machine for container creation.

### 2. Listing Images
```bash
# List all local images
docker images
docker image ls

# List images with specific format
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# List image IDs only
docker images -q

# Show dangling images
docker images --filter "dangling=true"
```

**Explanation**: Displays locally stored Docker images with repository, tag, image ID, creation date, and size.

### 3. Building Images
```bash
# Build image from Dockerfile in current directory
docker build -t myapp:latest .

# Build with specific Dockerfile
docker build -f Dockerfile.prod -t myapp:prod .

# Build with build arguments
docker build --build-arg VERSION=1.0 -t myapp:v1.0 .

# Build without cache
docker build --no-cache -t myapp:latest .
```

**Explanation**: Creates Docker images from Dockerfile instructions, allowing customization of application environments.

### 4. Tagging Images
```bash
# Tag existing image
docker tag nginx:latest myregistry.com/nginx:v1.0

# Tag with multiple tags
docker tag myapp:latest myapp:v1.0
docker tag myapp:latest myapp:stable
```

**Explanation**: Creates aliases for images, useful for versioning and registry organization.

### 5. Pushing Images
```bash
# Push to Docker Hub
docker push username/myapp:latest

# Push to private registry
docker push myregistry.com/myapp:v1.0

# Push all tags
docker push --all-tags username/myapp
```

**Explanation**: Uploads images to Docker registries for sharing and deployment.

### 6. Removing Images
```bash
# Remove single image
docker rmi nginx:latest

# Remove multiple images
docker rmi nginx redis ubuntu

# Remove by image ID
docker rmi 3fa112fd3642

# Force remove image
docker rmi -f myapp:latest

# Remove dangling images
docker image prune

# Remove all unused images
docker image prune -a
```

**Explanation**: Deletes images from local storage to free up disk space.

## Container Management Commands

### 1. Running Containers
```bash
# Run container in foreground
docker run ubuntu echo "Hello World"

# Run container in background (detached)
docker run -d nginx

# Run with custom name
docker run --name webserver -d nginx

# Run with port mapping
docker run -p 8080:80 -d nginx

# Run with environment variables
docker run -e MYSQL_ROOT_PASSWORD=secret -d mysql:8.0

# Run with volume mount
docker run -v /host/data:/container/data -d nginx

# Run interactive container
docker run -it ubuntu bash

# Run with resource limits
docker run -m 512m --cpus="1.0" -d nginx
```

**Explanation**: Creates and starts containers from images with various configuration options.

### 2. Listing Containers
```bash
# List running containers
docker ps

# List all containers (running and stopped)
docker ps -a

# List container IDs only
docker ps -q

# List with custom format
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# List containers by filter
docker ps --filter "status=running"
docker ps --filter "name=web"
```

**Explanation**: Shows container information including status, ports, names, and resource usage.

### 3. Container Lifecycle Management
```bash
# Start stopped container
docker start container_name

# Stop running container
docker stop container_name

# Restart container
docker restart container_name

# Pause container processes
docker pause container_name

# Unpause container
docker unpause container_name

# Kill container (force stop)
docker kill container_name
```

**Explanation**: Controls container execution states for management and troubleshooting.

### 4. Executing Commands in Containers
```bash
# Execute command in running container
docker exec container_name ls -la

# Interactive shell access
docker exec -it container_name bash
docker exec -it container_name sh

# Execute as specific user
docker exec -u root -it container_name bash

# Execute with environment variables
docker exec -e VAR=value container_name env
```

**Explanation**: Runs commands inside running containers for debugging and administration.

### 5. Container Inspection
```bash
# Inspect container details
docker inspect container_name

# Get specific information
docker inspect --format='{{.State.Status}}' container_name
docker inspect --format='{{.NetworkSettings.IPAddress}}' container_name

# View container processes
docker top container_name

# View container resource usage
docker stats container_name

# View container logs
docker logs container_name
docker logs -f container_name  # Follow logs
docker logs --tail 50 container_name  # Last 50 lines
```

**Explanation**: Provides detailed information about container configuration, state, and runtime metrics.

### 6. Copying Files
```bash
# Copy from container to host
docker cp container_name:/path/to/file /host/path/

# Copy from host to container
docker cp /host/path/file container_name:/path/to/

# Copy directory
docker cp container_name:/app/logs ./logs/
```

**Explanation**: Transfers files between containers and host system for data management.

### 7. Removing Containers
```bash
# Remove stopped container
docker rm container_name

# Force remove running container
docker rm -f container_name

# Remove multiple containers
docker rm container1 container2

# Remove all stopped containers
docker container prune

# Remove container after it stops
docker run --rm ubuntu echo "Hello"
```

**Explanation**: Deletes containers to free up resources and clean up the system.

## Network Management Commands

### 1. Network Operations
```bash
# List networks
docker network ls

# Create network
docker network create mynetwork
docker network create --driver bridge mybridge

# Inspect network
docker network inspect mynetwork

# Connect container to network
docker network connect mynetwork container_name

# Disconnect container from network
docker network disconnect mynetwork container_name

# Remove network
docker network rm mynetwork

# Remove unused networks
docker network prune
```

**Explanation**: Manages Docker networks for container communication and isolation.

### 2. Network Types and Examples
```bash
# Bridge network (default)
docker network create --driver bridge app-network

# Host network (use host networking)
docker run --network host nginx

# None network (no networking)
docker run --network none alpine

# Custom bridge with subnet
docker network create --driver bridge --subnet=192.168.1.0/24 custom-net
```

**Explanation**: Different network drivers provide various networking capabilities for containers.

## Volume Management Commands

### 1. Volume Operations
```bash
# Create volume
docker volume create myvolume

# List volumes
docker volume ls

# Inspect volume
docker volume inspect myvolume

# Remove volume
docker volume rm myvolume

# Remove unused volumes
docker volume prune
```

**Explanation**: Manages persistent data storage that survives container lifecycle.

### 2. Volume Usage Examples
```bash
# Named volume
docker run -v myvolume:/data nginx

# Bind mount
docker run -v /host/path:/container/path nginx

# Read-only mount
docker run -v /host/path:/container/path:ro nginx

# Temporary filesystem
docker run --tmpfs /tmp nginx
```

**Explanation**: Different mount types provide various data persistence and sharing options.

## Docker Compose Commands

### 1. Basic Compose Operations
```bash
# Start services
docker compose up

# Start in background
docker compose up -d

# Build and start
docker compose up --build

# Stop services
docker compose down

# Stop and remove volumes
docker compose down -v

# View running services
docker compose ps

# View logs
docker compose logs
docker compose logs service_name
```

**Explanation**: Manages multi-container applications defined in docker-compose.yml files.

### 2. Service Management
```bash
# Scale services
docker compose up --scale web=3

# Restart service
docker compose restart web

# Execute command in service
docker compose exec web bash

# Build specific service
docker compose build web

# Pull service images
docker compose pull
```

**Explanation**: Controls individual services within multi-container applications.

## System Management Commands

### 1. System Information
```bash
# Docker system information
docker system df

# Detailed system information
docker info

# Docker version
docker version

# System events
docker system events
```

**Explanation**: Provides system-wide Docker information and monitoring.

### 2. Cleanup Commands
```bash
# Remove unused containers, networks, images
docker system prune

# Remove everything including volumes
docker system prune -a --volumes

# Remove only containers
docker container prune

# Remove only images
docker image prune

# Remove only networks
docker network prune

# Remove only volumes
docker volume prune
```

**Explanation**: Cleans up Docker resources to free disk space and maintain system health.

## Registry and Authentication Commands

### 1. Registry Operations
```bash
# Login to registry
docker login
docker login myregistry.com

# Logout from registry
docker logout

# Search Docker Hub
docker search nginx

# Pull from specific registry
docker pull myregistry.com/myapp:latest
```

**Explanation**: Manages authentication and interaction with Docker registries.

## Advanced Docker Commands

### 1. Container Resource Management
```bash
# Set memory limit
docker run -m 512m nginx

# Set CPU limit
docker run --cpus="1.5" nginx

# Set CPU shares
docker run --cpu-shares=512 nginx

# Set swap limit
docker run --memory=1g --memory-swap=2g nginx

# Update running container resources
docker update --memory=1g --cpus="2" container_name
```

**Explanation**: Controls resource allocation for containers to prevent resource exhaustion.

### 2. Security and Capabilities
```bash
# Run as specific user
docker run -u 1000:1000 nginx

# Drop capabilities
docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE nginx

# Read-only root filesystem
docker run --read-only nginx

# Security options
docker run --security-opt no-new-privileges nginx
```

**Explanation**: Enhances container security through user management and capability restrictions.

### 3. Health Checks
```bash
# Run with health check
docker run --health-cmd="curl -f http://localhost/" --health-interval=30s nginx

# Check container health
docker inspect --format='{{.State.Health.Status}}' container_name
```

**Explanation**: Monitors container health and enables automatic recovery mechanisms.

## Dockerfile Commands

### 1. Basic Dockerfile Example
```dockerfile
# Use official base image
FROM node:16-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Set user
USER node

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start application
CMD ["npm", "start"]
```

**Explanation**: Defines how to build a Docker image with application code and dependencies.

### 2. Multi-stage Build Example
```dockerfile
# Build stage
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:16-alpine AS production
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY --from=builder /app/dist ./dist
USER node
CMD ["npm", "start"]
```

**Explanation**: Optimizes image size by separating build and runtime environments.

## Docker Compose Example

### 1. Basic docker-compose.yml
```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - db
    volumes:
      - ./logs:/app/logs
    networks:
      - app-network

  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - app-network

volumes:
  db-data:

networks:
  app-network:
    driver: bridge
```

**Explanation**: Defines multi-container application with services, networks, and volumes.

## Troubleshooting Commands

### 1. Debugging Containers
```bash
# View container logs
docker logs --details container_name

# Follow logs in real-time
docker logs -f container_name

# Check container processes
docker top container_name

# Inspect container configuration
docker inspect container_name

# Check container resource usage
docker stats container_name

# Access container filesystem
docker exec -it container_name sh
```

**Explanation**: Diagnoses container issues through logs, process monitoring, and direct access.

### 2. Network Troubleshooting
```bash
# Test network connectivity
docker exec container_name ping google.com

# Check network configuration
docker network inspect bridge

# List container networks
docker inspect container_name | grep NetworkMode

# Test port connectivity
docker exec container_name netstat -tlnp
```

**Explanation**: Diagnoses network connectivity and configuration issues.

## Performance Monitoring

### 1. Resource Monitoring
```bash
# Real-time resource usage
docker stats

# Historical resource usage
docker stats --no-stream

# Container processes
docker top container_name

# System resource usage
docker system df
```

**Explanation**: Monitors container and system resource utilization for performance optimization.

## Best Practices Commands

### 1. Image Optimization
```bash
# Build with specific target
docker build --target production -t myapp:prod .

# Build with cache from registry
docker build --cache-from myapp:latest -t myapp:new .

# Squash layers (experimental)
docker build --squash -t myapp:squashed .
```

**Explanation**: Optimizes image builds for size and performance.

### 2. Security Scanning
```bash
# Scan image for vulnerabilities (if available)
docker scan myapp:latest

# Check image history
docker history myapp:latest

# Export container filesystem
docker export container_name > container.tar
```

**Explanation**: Analyzes images for security vulnerabilities and layer composition.

## Command Cheat Sheet

### Quick Reference
```bash
# Container lifecycle
docker run -d --name app nginx          # Create and start
docker stop app                         # Stop
docker start app                        # Start
docker restart app                      # Restart
docker rm app                          # Remove

# Image management
docker pull nginx                       # Download
docker build -t app .                  # Build
docker push app                        # Upload
docker rmi app                         # Remove

# Information
docker ps                              # List containers
docker images                          # List images
docker logs app                        # View logs
docker inspect app                     # Detailed info

# Cleanup
docker system prune                    # Clean unused resources
docker container prune                 # Clean containers
docker image prune                     # Clean images
```

## Verification Checklist

- ✅ Basic Docker commands understood and tested
- ✅ Container lifecycle management practiced
- ✅ Image operations completed successfully
- ✅ Network and volume management configured
- ✅ Docker Compose multi-container setup working
- ✅ Troubleshooting commands familiar
- ✅ Security and resource management applied
- ✅ Performance monitoring implemented
- ✅ Best practices commands utilized

---

**Next Steps**: Proceed to Task-Docker-03 for advanced Docker topics including orchestration, security, and production deployment strategies.
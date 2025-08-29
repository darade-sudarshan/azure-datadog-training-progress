# Task-Docker-03: Dockerfile, Docker Compose, and Docker Swarm

## Overview
This task covers advanced Docker concepts including Dockerfile creation, Docker Compose for multi-container applications, and Docker Swarm for container orchestration with detailed syntax explanations.

## Part 1: Dockerfile

### What is a Dockerfile?
A Dockerfile is a text file containing instructions to build Docker images automatically. Each instruction creates a layer in the image.

### Dockerfile Syntax and Instructions

#### 1. FROM - Base Image
```dockerfile
# Use official base image
FROM ubuntu:20.04

# Use specific version
FROM node:16-alpine

# Multi-stage build
FROM node:16 AS builder
```
**Explanation**: Specifies the base image for the build. Must be the first instruction (except ARG).

#### 2. LABEL - Metadata
```dockerfile
# Add metadata
LABEL version="1.0"
LABEL description="My web application"
LABEL maintainer="developer@company.com"

# Multiple labels in one instruction
LABEL version="1.0" \
      description="My web application" \
      maintainer="developer@company.com"
```
**Explanation**: Adds metadata to images as key-value pairs for documentation and organization.

#### 3. ARG - Build Arguments
```dockerfile
# Define build argument
ARG VERSION=latest
ARG BUILD_DATE

# Use in FROM instruction
FROM node:${VERSION}

# Use in other instructions
RUN echo "Build date: ${BUILD_DATE}"
```
**Explanation**: Defines variables that users can pass at build-time with `docker build --build-arg`.

#### 4. ENV - Environment Variables
```dockerfile
# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000
ENV DATABASE_URL=postgresql://localhost/mydb

# Multiple variables
ENV NODE_ENV=production \
    PORT=3000 \
    DEBUG=false
```
**Explanation**: Sets environment variables available during build and runtime.

#### 5. WORKDIR - Working Directory
```dockerfile
# Set working directory
WORKDIR /app

# Create and set directory
WORKDIR /usr/src/app

# Use variables
ENV APP_HOME=/app
WORKDIR $APP_HOME
```
**Explanation**: Sets the working directory for subsequent instructions. Creates directory if it doesn't exist.

#### 6. COPY and ADD - File Operations
```dockerfile
# Copy files from build context
COPY package.json ./
COPY src/ ./src/
COPY . .

# Copy with ownership
COPY --chown=node:node package.json ./

# ADD with additional features (URLs, tar extraction)
ADD https://example.com/file.tar.gz /tmp/
ADD archive.tar.gz /opt/
```
**Explanation**: COPY copies files/directories. ADD has additional features but COPY is preferred for simple file copying.

#### 7. RUN - Execute Commands
```dockerfile
# Execute commands
RUN apt-get update && apt-get install -y curl

# Multiple commands in one layer
RUN apt-get update && \
    apt-get install -y \
        curl \
        wget \
        vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Use exec form
RUN ["npm", "install"]
```
**Explanation**: Executes commands during image build. Each RUN creates a new layer.

#### 8. CMD - Default Command
```dockerfile
# Shell form
CMD npm start

# Exec form (preferred)
CMD ["npm", "start"]

# With parameters
CMD ["node", "server.js"]
```
**Explanation**: Provides default command when container starts. Can be overridden by docker run arguments.

#### 9. ENTRYPOINT - Container Entry Point
```dockerfile
# Exec form
ENTRYPOINT ["docker-entrypoint.sh"]

# Combined with CMD
ENTRYPOINT ["node"]
CMD ["server.js"]

# Shell form
ENTRYPOINT exec java -jar app.jar
```
**Explanation**: Configures container to run as executable. Cannot be overridden, only appended to.

#### 10. EXPOSE - Port Declaration
```dockerfile
# Expose single port
EXPOSE 3000

# Expose multiple ports
EXPOSE 80 443

# Expose with protocol
EXPOSE 53/udp
EXPOSE 80/tcp
```
**Explanation**: Documents which ports the container listens on. Doesn't actually publish ports.

#### 11. VOLUME - Mount Points
```dockerfile
# Create mount point
VOLUME ["/data"]

# Multiple volumes
VOLUME ["/var/log", "/var/db"]

# String form
VOLUME /data
```
**Explanation**: Creates mount points for external volumes or other containers.

#### 12. USER - Set User
```dockerfile
# Set user by name
USER node

# Set user by UID
USER 1000

# Set user and group
USER node:node
```
**Explanation**: Sets the user for subsequent instructions and container runtime.

#### 13. HEALTHCHECK - Health Monitoring
```dockerfile
# Basic health check
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Disable health check
HEALTHCHECK NONE

# Custom health check script
HEALTHCHECK --interval=5m --timeout=3s \
  CMD /health-check.sh
```
**Explanation**: Defines how to test container health status.

### Complete Dockerfile Examples

#### 1. Node.js Application
```dockerfile
# Use official Node.js runtime
FROM node:16-alpine

# Set metadata
LABEL version="1.0" \
      description="Node.js web application"

# Create app directory
WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Copy application code
COPY --chown=nextjs:nodejs . .

# Switch to non-root user
USER nextjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start application
CMD ["npm", "start"]
```

#### 2. Multi-stage Build
```dockerfile
# Build stage
FROM node:16-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies
RUN npm ci

# Copy source code
COPY . .

# Build application
RUN npm run build

# Production stage
FROM node:16-alpine AS production

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy built application from builder stage
COPY --from=builder /app/dist ./dist

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Change ownership
RUN chown -R nextjs:nodejs /app

USER nextjs

EXPOSE 3000

CMD ["npm", "start"]
```

#### 3. Python Application
```dockerfile
FROM python:3.9-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libpq-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Create non-root user
RUN useradd --create-home --shell /bin/bash app && \
    chown -R app:app /app

USER app

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health/ || exit 1

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "myapp.wsgi:application"]
```

## Part 2: Docker Compose

### What is Docker Compose?
Docker Compose is a tool for defining and running multi-container Docker applications using YAML files.

### Docker Compose File Syntax

#### 1. Version and Services
```yaml
version: '3.8'

services:
  web:
    # Service configuration
  db:
    # Service configuration
```
**Explanation**: Specifies Compose file format version and defines services.

#### 2. Service Configuration

##### Build Context
```yaml
services:
  web:
    # Build from Dockerfile
    build: .
    
    # Build with context and dockerfile
    build:
      context: .
      dockerfile: Dockerfile.prod
      args:
        - VERSION=1.0
        - BUILD_DATE=2024-01-01
```
**Explanation**: Defines how to build the service image.

##### Image Specification
```yaml
services:
  web:
    # Use existing image
    image: nginx:latest
    
  db:
    # Use specific version
    image: postgres:13-alpine
```
**Explanation**: Specifies pre-built image to use for the service.

##### Container Name
```yaml
services:
  web:
    container_name: my-web-app
    image: nginx
```
**Explanation**: Sets custom container name instead of generated name.

##### Port Mapping
```yaml
services:
  web:
    ports:
      - "8080:80"          # host:container
      - "443:443"
      - "127.0.0.1:8081:81"  # bind to specific interface
```
**Explanation**: Maps host ports to container ports.

##### Environment Variables
```yaml
services:
  web:
    environment:
      - NODE_ENV=production
      - DEBUG=false
      - DATABASE_URL=postgresql://db:5432/myapp
    
    # Or as object
    environment:
      NODE_ENV: production
      DEBUG: "false"
```
**Explanation**: Sets environment variables for the container.

##### Environment Files
```yaml
services:
  web:
    env_file:
      - .env
      - .env.local
```
**Explanation**: Loads environment variables from files.

##### Volumes
```yaml
services:
  web:
    volumes:
      - ./src:/app/src                    # bind mount
      - node_modules:/app/node_modules    # named volume
      - /tmp:/tmp:ro                      # read-only mount
```
**Explanation**: Defines volume mounts for data persistence and sharing.

##### Networks
```yaml
services:
  web:
    networks:
      - frontend
      - backend
```
**Explanation**: Connects service to specific networks.

##### Dependencies
```yaml
services:
  web:
    depends_on:
      - db
      - redis
    
    # With conditions (requires healthchecks)
    depends_on:
      db:
        condition: service_healthy
```
**Explanation**: Defines service startup order and dependencies.

##### Resource Limits
```yaml
services:
  web:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```
**Explanation**: Sets resource constraints for the service.

##### Health Checks
```yaml
services:
  web:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```
**Explanation**: Defines health check configuration.

##### Restart Policy
```yaml
services:
  web:
    restart: unless-stopped
    # Options: no, always, on-failure, unless-stopped
```
**Explanation**: Sets container restart behavior.

#### 3. Networks Configuration
```yaml
networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
  external-network:
    external: true
    name: my-existing-network
```
**Explanation**: Defines custom networks for service communication.

#### 4. Volumes Configuration
```yaml
volumes:
  db-data:
    driver: local
  app-data:
    external: true
    name: my-existing-volume
```
**Explanation**: Defines named volumes for data persistence.

#### 5. Secrets (Docker Swarm)
```yaml
secrets:
  db-password:
    file: ./db_password.txt
  api-key:
    external: true
    name: my-api-key
```
**Explanation**: Manages sensitive data securely.

### Complete Docker Compose Examples

#### 1. Web Application with Database
```yaml
version: '3.8'

services:
  web:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://postgres:password@db:5432/myapp
    depends_on:
      - db
    volumes:
      - ./logs:/app/logs
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:13-alpine
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - db-data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:6-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis-data:/data
    networks:
      - app-network
    restart: unless-stopped

volumes:
  db-data:
  redis-data:

networks:
  app-network:
    driver: bridge
```

#### 2. Microservices Architecture
```yaml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - api
      - frontend
    networks:
      - frontend-network
    restart: unless-stopped

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    expose:
      - "3000"
    environment:
      - REACT_APP_API_URL=http://api:4000
    networks:
      - frontend-network
    restart: unless-stopped

  api:
    build:
      context: ./api
      dockerfile: Dockerfile
    expose:
      - "4000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/api
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
    networks:
      - frontend-network
      - backend-network
    restart: unless-stopped

  worker:
    build:
      context: ./api
      dockerfile: Dockerfile
    command: npm run worker
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/api
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
    networks:
      - backend-network
    restart: unless-stopped

  db:
    image: postgres:13-alpine
    environment:
      - POSTGRES_DB=api
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - backend-network
    restart: unless-stopped

  redis:
    image: redis:6-alpine
    volumes:
      - redis-data:/data
    networks:
      - backend-network
    restart: unless-stopped

volumes:
  db-data:
  redis-data:

networks:
  frontend-network:
    driver: bridge
  backend-network:
    driver: bridge
    internal: true
```

### Docker Compose Commands

#### Basic Operations
```bash
# Start services
docker compose up
docker compose up -d                    # detached mode
docker compose up --build              # rebuild images
docker compose up --scale web=3        # scale service

# Stop services
docker compose down
docker compose down -v                 # remove volumes
docker compose down --rmi all          # remove images

# View services
docker compose ps
docker compose top

# View logs
docker compose logs
docker compose logs web
docker compose logs -f web             # follow logs

# Execute commands
docker compose exec web bash
docker compose run web npm test
```

## Part 3: Docker Swarm

### What is Docker Swarm?
Docker Swarm is Docker's native clustering and orchestration solution for managing multiple Docker hosts as a single virtual system.

### Swarm Architecture
- **Manager Nodes**: Control the swarm, schedule services
- **Worker Nodes**: Run containers
- **Services**: Define desired state of containers
- **Tasks**: Individual container instances

### Swarm Initialization and Management

#### 1. Initialize Swarm
```bash
# Initialize swarm on manager node
docker swarm init

# Initialize with specific IP
docker swarm init --advertise-addr 192.168.1.100

# Get join tokens
docker swarm join-token worker
docker swarm join-token manager
```

#### 2. Join Nodes
```bash
# Join as worker
docker swarm join --token SWMTKN-1-xxx 192.168.1.100:2377

# Join as manager
docker swarm join --token SWMTKN-1-xxx 192.168.1.100:2377
```

#### 3. Node Management
```bash
# List nodes
docker node ls

# Inspect node
docker node inspect node-name

# Promote worker to manager
docker node promote worker-node

# Demote manager to worker
docker node demote manager-node

# Remove node
docker node rm node-name

# Update node availability
docker node update --availability drain node-name
```

### Docker Swarm Services

#### 1. Service Creation
```bash
# Create simple service
docker service create --name web nginx

# Create with replicas
docker service create --name web --replicas 3 nginx

# Create with port mapping
docker service create --name web --publish 80:80 nginx

# Create with constraints
docker service create --name web --constraint 'node.role==worker' nginx

# Create with resource limits
docker service create --name web --limit-memory 512m --limit-cpu 0.5 nginx
```

#### 2. Service Management
```bash
# List services
docker service ls

# Inspect service
docker service inspect web

# View service logs
docker service logs web

# Scale service
docker service scale web=5

# Update service
docker service update --image nginx:alpine web

# Remove service
docker service rm web
```

#### 3. Service Configuration
```bash
# Create with environment variables
docker service create --name web \
  --env NODE_ENV=production \
  --env PORT=3000 \
  myapp:latest

# Create with volumes
docker service create --name web \
  --mount type=volume,source=web-data,target=/data \
  nginx

# Create with secrets
docker service create --name web \
  --secret db-password \
  myapp:latest

# Create with configs
docker service create --name web \
  --config source=nginx.conf,target=/etc/nginx/nginx.conf \
  nginx
```

### Docker Stack (Swarm Compose)

#### 1. Stack Deployment
```yaml
# docker-stack.yml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      placement:
        constraints:
          - node.role == worker
    networks:
      - webnet

  visualizer:
    image: dockersamples/visualizer:stable
    ports:
      - "8080:8080"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
    deploy:
      placement:
        constraints:
          - node.role == manager
    networks:
      - webnet

networks:
  webnet:
    driver: overlay
```

#### 2. Stack Commands
```bash
# Deploy stack
docker stack deploy -c docker-stack.yml mystack

# List stacks
docker stack ls

# List stack services
docker stack services mystack

# List stack tasks
docker stack ps mystack

# Remove stack
docker stack rm mystack
```

### Swarm Networking

#### 1. Overlay Networks
```bash
# Create overlay network
docker network create --driver overlay mynetwork

# Create with encryption
docker network create --driver overlay --opt encrypted mynetwork

# Attach service to network
docker service create --name web --network mynetwork nginx
```

#### 2. Ingress Network
```bash
# Services automatically join ingress network for published ports
docker service create --name web --publish 80:80 nginx
```

### Swarm Security

#### 1. Secrets Management
```bash
# Create secret from file
docker secret create db-password ./password.txt

# Create secret from stdin
echo "mypassword" | docker secret create db-password -

# List secrets
docker secret ls

# Use secret in service
docker service create --name web --secret db-password myapp:latest
```

#### 2. Config Management
```bash
# Create config
docker config create nginx.conf ./nginx.conf

# List configs
docker config ls

# Use config in service
docker service create --name web \
  --config source=nginx.conf,target=/etc/nginx/nginx.conf \
  nginx
```

### Complete Swarm Stack Example

```yaml
version: '3.8'

services:
  web:
    image: myapp:latest
    ports:
      - "80:80"
    environment:
      - DATABASE_URL_FILE=/run/secrets/db-url
    secrets:
      - db-url
    configs:
      - source: app-config
        target: /app/config.json
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      placement:
        constraints:
          - node.labels.type == web
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    networks:
      - frontend
      - backend
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:13-alpine
    environment:
      - POSTGRES_PASSWORD_FILE=/run/secrets/db-password
    secrets:
      - db-password
    volumes:
      - db-data:/var/lib/postgresql/data
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.labels.type == database
      restart_policy:
        condition: on-failure
    networks:
      - backend

  redis:
    image: redis:6-alpine
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.labels.type == cache
    networks:
      - backend

volumes:
  db-data:
    driver: local

networks:
  frontend:
    driver: overlay
  backend:
    driver: overlay
    internal: true

secrets:
  db-password:
    external: true
  db-url:
    external: true

configs:
  app-config:
    external: true
```

## Best Practices

### Dockerfile Best Practices
1. **Use specific base image tags**
2. **Minimize layers by combining RUN commands**
3. **Use .dockerignore to exclude unnecessary files**
4. **Run as non-root user**
5. **Use multi-stage builds for optimization**
6. **Add health checks**
7. **Set appropriate resource limits**

### Docker Compose Best Practices
1. **Use environment-specific compose files**
2. **Define networks explicitly**
3. **Use named volumes for persistent data**
4. **Set restart policies**
5. **Use health checks**
6. **Organize services logically**

### Docker Swarm Best Practices
1. **Use odd number of manager nodes**
2. **Implement proper secret management**
3. **Use placement constraints effectively**
4. **Monitor service health**
5. **Plan for rolling updates**
6. **Implement proper logging strategy**

## Verification Checklist

- ✅ Dockerfile syntax and instructions understood
- ✅ Multi-stage builds implemented
- ✅ Docker Compose file structure mastered
- ✅ Multi-container applications deployed
- ✅ Docker Swarm cluster initialized
- ✅ Services deployed and scaled
- ✅ Stack deployment completed
- ✅ Secrets and configs managed
- ✅ Best practices applied

---

**Next Steps**: Proceed to advanced container orchestration with Kubernetes or explore container security and monitoring solutions.
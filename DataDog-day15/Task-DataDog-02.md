# Task-DataDog-02: DataDog Agent for Docker Containers

## Overview

DataDog Agent can be deployed as a Docker container to monitor containerized applications and infrastructure. This approach provides seamless monitoring for Docker environments, Kubernetes clusters, and container orchestration platforms.

## Prerequisites

- Docker installed and running
- DataDog API key
- Azure VM or local Docker environment
- Basic understanding of Docker concepts

## Part 1: DataDog Agent Container Deployment

### Step 1: Basic Agent Container
```bash
# Run DataDog agent container
docker run -d --name datadog-agent \
  -e DD_API_KEY=<YOUR_API_KEY> \
  -e DD_SITE="datadoghq.com" \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /proc/:/host/proc/:ro \
  -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
  datadog/agent:latest
```

### Step 2: Enhanced Agent with Full Monitoring
```bash
# Run with comprehensive monitoring
docker run -d --name datadog-agent \
  --cgroupns host \
  --pid host \
  -e DD_API_KEY=<YOUR_API_KEY> \
  -e DD_SITE="datadoghq.com" \
  -e DD_HOSTNAME="docker-host" \
  -e DD_TAGS="env:production,team:devops" \
  -e DD_PROCESS_AGENT_ENABLED=true \
  -e DD_LOGS_ENABLED=true \
  -e DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL=true \
  -e DD_CONTAINER_EXCLUDE="name:datadog-agent" \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /proc/:/host/proc/:ro \
  -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
  -v /var/lib/docker/containers:/var/lib/docker/containers:ro \
  -v /opt/datadog-agent/run:/opt/datadog-agent/run:rw \
  datadog/agent:latest
```
[Docker Container Output](Task02_images/output.txt)

## Part 2: Docker Compose Configuration

### Step 1: Create docker-compose.yml
```yaml
version: '3.8'

services:
  datadog-agent:
    image: datadog/agent:latest
    container_name: datadog-agent
    environment:
      - DD_API_KEY=${DD_API_KEY}
      - DD_SITE=datadoghq.com
      - DD_HOSTNAME=docker-compose-host
      - DD_TAGS=env:production,orchestrator:compose
      - DD_PROCESS_AGENT_ENABLED=true
      - DD_LOGS_ENABLED=true
      - DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL=true
      - DD_CONTAINER_EXCLUDE=name:datadog-agent
      - DD_APM_ENABLED=true
      - DD_APM_NON_LOCAL_TRAFFIC=true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /proc/:/host/proc/:ro
      - /sys/fs/cgroup/:/host/sys/fs/cgroup:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
    ports:
      - "8126:8126"  # APM traces
    pid: host
    restart: unless-stopped

  # Sample application to monitor
  web-app:
    image: nginx:alpine
    container_name: sample-web-app
    ports:
      - "80:80"
    labels:
      com.datadoghq.ad.logs: '[{"source": "nginx", "service": "web-app"}]'
      com.datadoghq.ad.check_names: '["nginx"]'
      com.datadoghq.ad.init_configs: '[{}]'
      com.datadoghq.ad.instances: '[{"nginx_status_url": "http://%%host%%:%%port%%/nginx_status"}]'
```

### Step 2: Environment File (.env)
```bash
# Create .env file
cat > .env << EOF
DD_API_KEY=your_datadog_api_key_here
EOF
```

### Step 3: Deploy with Docker Compose
```bash
# Start services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs datadog-agent
```

## Part 3: Container Monitoring Configuration

### Step 1: Enable Container Discovery
```bash
# Run agent with autodiscovery
docker run -d --name datadog-agent \
  -e DD_API_KEY=<YOUR_API_KEY> \
  -e DD_SITE="datadoghq.com" \
  -e DD_PROCESS_AGENT_ENABLED=true \
  -e DD_LOGS_ENABLED=true \
  -e DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL=true \
  -e DD_AC_EXCLUDE="name:datadog-agent" \
  -e DD_DOCKER_LABELS_AS_TAGS='{"env":"env","version":"version"}' \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /proc/:/host/proc/:ro \
  -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
  -v /var/lib/docker/containers:/var/lib/docker/containers:ro \
  datadog/agent:latest
```

### Step 2: Application Container with Labels
```bash
# Run application with DataDog labels
docker run -d --name web-server \
  --label com.datadoghq.ad.logs='[{"source": "nginx", "service": "web-server"}]' \
  --label com.datadoghq.ad.check_names='["nginx"]' \
  --label com.datadoghq.ad.init_configs='[{}]' \
  --label com.datadoghq.ad.instances='[{"nginx_status_url": "http://%%host%%:%%port%%/nginx_status"}]' \
  -p 8080:80 \
  nginx:alpine
```

## Part 4: APM (Application Performance Monitoring)

### Step 1: Enable APM in Agent
```bash
# Agent with APM enabled
docker run -d --name datadog-agent \
  -e DD_API_KEY=<YOUR_API_KEY> \
  -e DD_APM_ENABLED=true \
  -e DD_APM_NON_LOCAL_TRAFFIC=true \
  -p 8126:8126 \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /proc/:/host/proc/:ro \
  -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
  datadog/agent:latest
```

### Step 2: Sample Python App with APM
```python
# app.py
from flask import Flask
from ddtrace import tracer
from ddtrace.contrib.flask import TraceMiddleware

app = Flask(__name__)
TraceMiddleware(app, tracer, service="sample-app")

@app.route('/')
def hello():
    return "Hello from DataDog monitored app!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

```dockerfile
# Dockerfile for Python app
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
```

```txt
# requirements.txt
Flask==2.3.3
ddtrace==1.20.0
```

### Step 3: Deploy APM-enabled Application
```bash
# Build and run application
docker build -t sample-app .
docker run -d --name sample-app \
  -e DD_AGENT_HOST=datadog-agent \
  -e DD_TRACE_AGENT_PORT=8126 \
  -e DD_SERVICE=sample-app \
  -e DD_ENV=production \
  -e DD_VERSION=1.0.0 \
  --link datadog-agent \
  -p 5000:5000 \
  sample-app
```

## Part 5: Log Collection

### Step 1: Enable Log Collection
```bash
# Agent with log collection
docker run -d --name datadog-agent \
  -e DD_API_KEY=<YOUR_API_KEY> \
  -e DD_LOGS_ENABLED=true \
  -e DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL=true \
  -e DD_LOGS_CONFIG_AUTO_MULTI_LINE_DETECTION=true \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /var/lib/docker/containers:/var/lib/docker/containers:ro \
  -v /proc/:/host/proc/:ro \
  -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
  datadog/agent:latest
```

### Step 2: Container with Custom Log Configuration
```bash
# Application with log labels
docker run -d --name app-with-logs \
  --label com.datadoghq.ad.logs='[{"source": "python", "service": "my-app", "log_processing_rules": [{"type": "multi_line", "name": "log_start_with_date", "pattern": "\\d{4}\\-(0?[1-9]|1[012])\\-(0?[1-9]|[12][0-9]|3[01])"}]}]' \
  python:3.9 \
  python -c "import time; [print(f'2023-01-01 INFO: Message {i}') or time.sleep(1) for i in range(1000)]"
```

## Part 6: Custom Metrics

### Step 1: DogStatsD Configuration
```bash
# Agent with DogStatsD
docker run -d --name datadog-agent \
  -e DD_API_KEY=<YOUR_API_KEY> \
  -e DD_DOGSTATSD_NON_LOCAL_TRAFFIC=true \
  -p 8125:8125/udp \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /proc/:/host/proc/:ro \
  -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
  datadog/agent:latest
```

### Step 2: Application Sending Custom Metrics
```python
# metrics_app.py
from datadog import initialize, statsd
import time
import random

options = {
    'statsd_host': 'datadog-agent',
    'statsd_port': 8125
}
initialize(**options)

while True:
    statsd.increment('custom.requests.count', tags=['env:production'])
    statsd.gauge('custom.queue.size', random.randint(1, 100))
    statsd.histogram('custom.response.time', random.uniform(0.1, 2.0))
    time.sleep(10)
```


## Part 7: Monitoring and Verification

### Step 1: Check Agent Status
```bash
# Check agent container logs
docker logs datadog-agent

# Execute status command in container
docker exec datadog-agent agent status

# Check connectivity
docker exec datadog-agent agent configcheck
```
[Docker Container Logs](Task02_images/logs.txt)

### Step 2: Verify Container Metrics
```bash
# List monitored containers
docker exec datadog-agent agent status | grep -A 20 "Container Detection"

# Check integrations
docker exec datadog-agent agent status | grep -A 10 "Running Checks"
```

## Part 8: Troubleshooting

### Common Issues
```bash
# Permission issues
docker run --privileged datadog/agent:latest

# Network connectivity
docker exec datadog-agent curl -v https://api.datadoghq.com/api/v1/validate

# Check agent configuration
docker exec datadog-agent agent configcheck

# Restart agent
docker restart datadog-agent
```

### Debug Mode
```bash
# Run agent in debug mode
docker run -d --name datadog-agent \
  -e DD_API_KEY=<YOUR_API_KEY> \
  -e DD_LOG_LEVEL=debug \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  datadog/agent:latest
```

## Part 9: Cleanup

### Remove Containers
```bash
# Stop and remove DataDog agent
docker stop datadog-agent
docker rm datadog-agent

# Clean up with Docker Compose
docker-compose down -v

# Remove images
docker rmi datadog/agent:latest
```

## Key Features

1. **Container Monitoring**: Automatic discovery and monitoring of Docker containers
2. **APM Integration**: Application performance monitoring for containerized apps
3. **Log Collection**: Centralized logging from all containers
4. **Custom Metrics**: DogStatsD integration for application metrics
5. **Kubernetes Support**: Native Kubernetes monitoring capabilities
6. **Autodiscovery**: Automatic service discovery and configuration

## Best Practices

- Use specific agent versions instead of `latest`
- Configure resource limits for the agent container
- Use secrets management for API keys
- Enable only required monitoring features
- Tag containers appropriately for organization
- Monitor agent resource usage
- Regular agent updates for security patches


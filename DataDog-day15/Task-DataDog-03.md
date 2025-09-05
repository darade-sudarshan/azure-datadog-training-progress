# Task-DataDog-03: Kubernetes Monitoring with DataDog (AKS & Minikube)

## Overview

This task covers implementing comprehensive DataDog monitoring for Kubernetes environments, including Azure Kubernetes Service (AKS) and local Minikube clusters. You'll learn to monitor container metrics, application performance, logs, and cluster health.

## Prerequisites

- DataDog account with API key
- Azure CLI installed and configured
- kubectl installed
- Minikube installed (for local testing)
- Helm 3.x installed

## Part 1: AKS Integration with DataDog

### Step 1: Create AKS Cluster

```bash
# Create resource group
az group create --name sa1_test_eic_SudarshanDarade --location southeastasia

# Create AKS cluster
az aks create \
  --resource-group sa1_test_eic_SudarshanDarade \
  --name aks-datadog-cluster \
  --node-count 2 \
  --node-vm-size Standard_D2s_v3 \
  --enable-addons monitoring \
  --generate-ssh-keys

# Get credentials
az aks get-credentials --resource-group sa1_test_eic_SudarshanDarade --name aks-datadog-cluster
```

### Step 2: Install DataDog Agent via Helm

```bash
# Add DataDog Helm repository
helm repo add datadog https://helm.datadoghq.com
helm repo update

# Create namespace
kubectl create namespace datadog

# Create secret with API key
kubectl create secret generic datadog-secret \
  --from-literal api-key=<YOUR_DATADOG_API_KEY> \
  --namespace datadog
```

### Step 3: DataDog Agent Configuration

Create `datadog-values.yaml`:

```yaml
datadog:
  apiKey: <YOUR_DATADOG_API_KEY>
  site: datadoghq.com
  
  # Enable logs collection
  logs:
    enabled: true
    containerCollectAll: true
  
  # Enable APM
  apm:
    enabled: true
    portEnabled: true
  
  # Enable process monitoring
  processAgent:
    enabled: true
    processCollection: true
  
  # Enable network monitoring
  networkMonitoring:
    enabled: true
  
  # Enable security monitoring
  securityAgent:
    runtime:
      enabled: true

# Enable cluster agent
clusterAgent:
  enabled: true
  metricsProvider:
    enabled: true
  
# Node agent configuration
agents:
  image:
    tag: "7.48.0"
  
  # Resource limits
  resources:
    requests:
      cpu: 200m
      memory: 256Mi
    limits:
      cpu: 200m
      memory: 256Mi
  
  # Enable auto-discovery
  containers:
    agent:
      env:
        - name: DD_KUBERNETES_KUBELET_HOST
          valueFrom:
            fieldRef:
              fieldPath: status.hostIP
```

### Step 4: Deploy DataDog Agent

```bash
# Install DataDog agent
helm install datadog-agent datadog/datadog \
  --namespace datadog \
  --values datadog-values.yaml

# Verify deployment
kubectl get pods -n datadog
kubectl get daemonset -n datadog
```

## Part 2: Minikube Integration

### Step 1: Start Minikube

```bash
# Start minikube with sufficient resources
minikube start --memory=4096 --cpus=2 --driver=docker

# Enable addons
minikube addons enable metrics-server
minikube addons enable ingress
```

### Step 2: Deploy DataDog on Minikube

```bash
# Create namespace
kubectl create namespace datadog

# Simplified values for minikube
cat > minikube-datadog-values.yaml << EOF
datadog:
  apiKey: <YOUR_DATADOG_API_KEY>
  site: datadoghq.com
  
  logs:
    enabled: true
    containerCollectAll: true
  
  apm:
    enabled: true
    portEnabled: true

clusterAgent:
  enabled: true

agents:
  image:
    tag: "7.48.0"
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 200m
      memory: 256Mi
EOF

# Install DataDog
helm install datadog-agent datadog/datadog \
  --namespace datadog \
  --values minikube-datadog-values.yaml
```

## Part 3: Sample Application Deployment

### Step 1: Deploy Sample Web Application

```yaml
# sample-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-web-app
  labels:
    app: sample-web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: sample-web-app
  template:
    metadata:
      labels:
        app: sample-web-app
      annotations:
        ad.datadoghq.com/sample-web-app.logs: '[{"source": "nginx", "service": "sample-web-app"}]'
        ad.datadoghq.com/sample-web-app.check_names: '["nginx"]'
        ad.datadoghq.com/sample-web-app.init_configs: '[{}]'
        ad.datadoghq.com/sample-web-app.instances: '[{"nginx_status_url": "http://%%host%%:%%port%%/nginx_status"}]'
    spec:
      containers:
      - name: sample-web-app
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
        env:
        - name: DD_AGENT_HOST
          valueFrom:
            fieldRef:
              fieldPath: status.hostIP
        - name: DD_TRACE_AGENT_PORT
          value: "8126"
---
apiVersion: v1
kind: Service
metadata:
  name: sample-web-app-service
spec:
  selector:
    app: sample-web-app
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```

```bash
kubectl apply -f sample-app.yaml
```

### Step 2: Deploy Application with Custom Metrics

```yaml
# custom-metrics-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: custom-metrics-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: custom-metrics-app
  template:
    metadata:
      labels:
        app: custom-metrics-app
      annotations:
        ad.datadoghq.com/custom-metrics-app.logs: '[{"source": "python", "service": "custom-metrics-app"}]'
    spec:
      containers:
      - name: custom-metrics-app
        image: python:3.9-slim
        command: ["/bin/sh"]
        args:
          - -c
          - |
            pip install datadog requests flask
            cat > app.py << 'EOF'
            from datadog import initialize, statsd
            from flask import Flask
            import time
            import random
            
            options = {
                'statsd_host': '127.0.0.1',
                'statsd_port': 8125,
            }
            initialize(**options)
            
            app = Flask(__name__)
            
            @app.route('/')
            def hello():
                # Custom metrics
                statsd.increment('custom.requests.count', tags=['endpoint:home'])
                statsd.histogram('custom.request.duration', random.uniform(0.1, 2.0))
                statsd.gauge('custom.active.users', random.randint(10, 100))
                return 'Hello from Custom Metrics App!'
            
            @app.route('/health')
            def health():
                statsd.increment('custom.health.checks')
                return 'OK'
            
            if __name__ == '__main__':
                app.run(host='0.0.0.0', port=5000)
            EOF
            python app.py
        ports:
        - containerPort: 5000
        env:
        - name: DD_AGENT_HOST
          valueFrom:
            fieldRef:
              fieldPath: status.hostIP
```

```bash
kubectl apply -f custom-metrics-app.yaml
```

## Part 4: Monitoring Configuration Examples

### Step 1: ConfigMap for Custom Checks

```yaml
# custom-checks-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: datadog-custom-checks
  namespace: datadog
data:
  kubernetes_state.yaml: |
    init_config:
    instances:
      - kube_state_url: http://kube-state-metrics:8080/metrics
        tags:
          - cluster:my-cluster
  
  custom_service_check.yaml: |
    init_config:
    instances:
      - url: http://sample-web-app-service/health
        name: sample_app_health
        timeout: 5
        tags:
          - service:sample-web-app
```

### Step 2: Service Monitor for Prometheus Metrics

```yaml
# service-monitor.yaml
apiVersion: v1
kind: Service
metadata:
  name: kube-state-metrics
  namespace: kube-system
  labels:
    app: kube-state-metrics
spec:
  ports:
  - port: 8080
    name: metrics
  selector:
    app: kube-state-metrics
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kube-state-metrics
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kube-state-metrics
  template:
    metadata:
      labels:
        app: kube-state-metrics
    spec:
      containers:
      - name: kube-state-metrics
        image: k8s.gcr.io/kube-state-metrics/kube-state-metrics:v2.6.0
        ports:
        - containerPort: 8080
```

## Part 5: Dashboard and Alerting Examples

### Step 1: Custom Dashboard JSON

```json
{
  "title": "Kubernetes Cluster Overview",
  "widgets": [
    {
      "definition": {
        "type": "timeseries",
        "requests": [
          {
            "q": "avg:kubernetes.cpu.usage.total{cluster_name:aks-datadog-cluster} by {pod_name}",
            "display_type": "line"
          }
        ],
        "title": "Pod CPU Usage"
      }
    },
    {
      "definition": {
        "type": "timeseries",
        "requests": [
          {
            "q": "avg:kubernetes.memory.usage{cluster_name:aks-datadog-cluster} by {pod_name}",
            "display_type": "line"
          }
        ],
        "title": "Pod Memory Usage"
      }
    },
    {
      "definition": {
        "type": "query_value",
        "requests": [
          {
            "q": "sum:kubernetes.pods.running{cluster_name:aks-datadog-cluster}",
            "aggregator": "last"
          }
        ],
        "title": "Running Pods"
      }
    }
  ]
}
```

### Step 2: Alert Configuration Examples

```yaml
# High CPU Alert
name: "High CPU Usage in Kubernetes Pod"
type: "metric alert"
query: "avg(last_5m):avg:kubernetes.cpu.usage.total{cluster_name:aks-datadog-cluster} by {pod_name} > 0.8"
message: |
  Pod {{pod_name.name}} in cluster {{cluster_name.name}} has high CPU usage: {{value}}%
  
  Troubleshooting steps:
  1. Check pod resource limits
  2. Review application performance
  3. Consider horizontal scaling

# Pod Restart Alert
name: "Pod Restart Detected"
type: "metric alert"
query: "change(sum(last_5m),last_5m):sum:kubernetes.containers.restarts{cluster_name:aks-datadog-cluster} by {pod_name} > 0"
message: |
  Pod {{pod_name.name}} has restarted {{value}} times in the last 5 minutes.
  
  Check logs: kubectl logs {{pod_name.name}} --previous

# Memory Usage Alert
name: "High Memory Usage"
type: "metric alert"
query: "avg(last_10m):avg:kubernetes.memory.usage_pct{cluster_name:aks-datadog-cluster} by {pod_name} > 85"
message: "Pod {{pod_name.name}} memory usage is {{value}}%"
```

## Part 6: Log Management Configuration

### Step 1: Log Processing Pipeline

```yaml
# log-pipeline-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: datadog-log-config
  namespace: datadog
data:
  log_processing_rules: |
    - type: exclude_at_match
      name: exclude_debug_logs
      pattern: "DEBUG"
    
    - type: include_at_match
      name: include_error_logs
      pattern: "ERROR|FATAL"
    
    - type: mask_sequences
      name: mask_credit_cards
      pattern: '\d{4}-\d{4}-\d{4}-\d{4}'
      replace_placeholder: "[MASKED_CC]"
```

### Step 2: Application Log Configuration

```yaml
# app-with-structured-logs.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: structured-logs-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: structured-logs-app
  template:
    metadata:
      labels:
        app: structured-logs-app
      annotations:
        ad.datadoghq.com/structured-logs-app.logs: |
          [{
            "source": "python",
            "service": "structured-logs-app",
            "log_processing_rules": [{
              "type": "multi_line",
              "name": "log_start_with_date",
              "pattern": "\\d{4}-\\d{2}-\\d{2}"
            }]
          }]
    spec:
      containers:
      - name: structured-logs-app
        image: python:3.9-slim
        command: ["/bin/sh"]
        args:
          - -c
          - |
            pip install structlog
            cat > log_app.py << 'EOF'
            import structlog
            import time
            import random
            
            structlog.configure(
                processors=[
                    structlog.stdlib.filter_by_level,
                    structlog.stdlib.add_logger_name,
                    structlog.stdlib.add_log_level,
                    structlog.stdlib.PositionalArgumentsFormatter(),
                    structlog.processors.TimeStamper(fmt="iso"),
                    structlog.processors.StackInfoRenderer(),
                    structlog.processors.format_exc_info,
                    structlog.processors.JSONRenderer()
                ],
                context_class=dict,
                logger_factory=structlog.stdlib.LoggerFactory(),
                wrapper_class=structlog.stdlib.BoundLogger,
                cache_logger_on_first_use=True,
            )
            
            logger = structlog.get_logger()
            
            while True:
                logger.info("Application running", 
                           user_id=random.randint(1, 1000),
                           action="page_view",
                           response_time=random.uniform(0.1, 2.0))
                
                if random.random() < 0.1:
                    logger.error("Database connection failed",
                                error_code="DB_CONN_001",
                                retry_count=3)
                
                time.sleep(5)
            EOF
            python log_app.py
```

## Part 7: Verification and Testing

### Step 1: Verify DataDog Agent Status

```bash
# Check agent pods
kubectl get pods -n datadog

# Check agent logs
kubectl logs -n datadog -l app=datadog-agent

# Check cluster agent
kubectl logs -n datadog -l app=datadog-cluster-agent

# Port forward to access agent status
kubectl port-forward -n datadog svc/datadog-cluster-agent 5005:5005
# Visit http://localhost:5005/status
```

### Step 2: Generate Test Traffic

```bash
# Create load testing pod
kubectl run load-test --image=busybox --rm -it --restart=Never -- /bin/sh

# Inside the pod, generate traffic
while true; do
  wget -q -O- http://sample-web-app-service/
  wget -q -O- http://custom-metrics-app:5000/
  sleep 1
done
```

### Step 3: Verify Metrics in DataDog

1. **Infrastructure Metrics**:
   - `kubernetes.cpu.usage.total`
   - `kubernetes.memory.usage`
   - `kubernetes.network.rx_bytes`
   - `kubernetes.pods.running`

2. **Custom Metrics**:
   - `custom.requests.count`
   - `custom.request.duration`
   - `custom.active.users`

3. **Log Verification**:
   - Check Logs section in DataDog
   - Filter by `source:nginx` or `source:python`
   - Verify structured logs are parsed correctly

## Part 8: Troubleshooting

### Common Issues and Solutions

1. **Agent Not Starting**:
```bash
# Check events
kubectl describe pod -n datadog <agent-pod-name>

# Check RBAC permissions
kubectl auth can-i get nodes --as=system:serviceaccount:datadog:datadog-agent
```

2. **Missing Metrics**:
```bash
# Check agent configuration
kubectl exec -n datadog <agent-pod> -- agent configcheck

# Check agent status
kubectl exec -n datadog <agent-pod> -- agent status
```

3. **Log Collection Issues**:
```bash
# Verify log collection is enabled
kubectl exec -n datadog <agent-pod> -- agent status | grep -A 10 "Logs Agent"

# Check log permissions
kubectl exec -n datadog <agent-pod> -- ls -la /var/log/pods/
```

## Cleanup

### AKS Cleanup
```bash
# Delete AKS cluster
az aks delete --resource-group sa1_test_eic_SudarshanDarade --name aks-datadog-cluster --yes --no-wait

# Delete resource group
az group delete --name sa1_test_eic_SudarshanDarade --yes --no-wait
```

### Minikube Cleanup
```bash
# Delete minikube cluster
minikube delete

# Remove DataDog Helm repo
helm repo remove datadog
```

## Best Practices

1. **Resource Management**:
   - Set appropriate resource limits for DataDog agents
   - Use node selectors for agent placement
   - Monitor agent resource consumption

2. **Security**:
   - Store API keys in Kubernetes secrets
   - Use RBAC for least privilege access
   - Enable security monitoring features

3. **Performance**:
   - Configure log sampling for high-volume applications
   - Use metric filters to reduce noise
   - Implement proper tagging strategy

4. **Monitoring Strategy**:
   - Create meaningful dashboards
   - Set up proactive alerts
   - Use composite monitors for complex scenarios

## Key Takeaways

- DataDog provides comprehensive Kubernetes monitoring capabilities
- Proper configuration enables deep visibility into cluster health
- Custom metrics and structured logging enhance observability
- Both AKS and Minikube can be effectively monitored with DataDog
- Proper resource management and security practices are essential

This completes the comprehensive DataDog Kubernetes monitoring setup for both AKS and Minikube environments.
#!/bin/bash
# docker-test.sh

print_test() {
    echo "Testing: $1"
}

print_result() {
    if [ $? -eq 0 ]; then
        echo "✅ $1 - PASSED"
    else
        echo "❌ $1 - FAILED"
    fi
}

# Test Docker installation
print_test "Docker installation"
docker --version >/dev/null 2>&1
print_result "Docker version check"

# Test Docker daemon
print_test "Docker daemon"
docker info >/dev/null 2>&1
print_result "Docker daemon connectivity"

# Test container run
print_test "Container execution"
docker run --rm hello-world >/dev/null 2>&1
print_result "Hello-world container"

# Test image operations
print_test "Image operations"
docker pull alpine:latest >/dev/null 2>&1
print_result "Image pull"

docker run --rm alpine:latest echo "Test successful" >/dev/null 2>&1
print_result "Alpine container run"

# Test Docker Compose
print_test "Docker Compose"
docker compose version >/dev/null 2>&1
print_result "Docker Compose version"

# Test volume operations
print_test "Volume operations"
docker volume create test-volume >/dev/null 2>&1
docker volume rm test-volume >/dev/null 2>&1
print_result "Volume create/remove"

# Test network operations
print_test "Network operations"
docker network create test-network >/dev/null 2>&1
docker network rm test-network >/dev/null 2>&1
print_result "Network create/remove"

echo "Docker installation test completed!"
# Multi-Architecture Docker Build with Kaniko

This project demonstrates how to build multi-architecture Docker images (amd64/arm64) using kaniko and test the builds.

## Files Overview

- `Dockerfile` - Enhanced Dockerfile with multi-architecture support and built-in testing
- `kaniko-build.yaml` - Kubernetes manifest for kaniko-based multi-architecture builds
- `test-build.sh` - Local testing script for Docker builds

## Features

- ✅ Multi-architecture support (amd64/arm64)
- ✅ Built-in architecture detection and build info
- ✅ Comprehensive build testing
- ✅ Health checks
- ✅ Network connectivity testing
- ✅ Tool version verification

## Local Testing

### Prerequisites

- Docker with buildx support
- bash shell

### Run Local Tests

```bash
# Make the script executable (if not already)
chmod +x test-build.sh

# Run the test script
./test-build.sh

# Or with custom image name and tag
IMAGE_NAME="my-app" TAG="v1.0.0" ./test-build.sh
```

## Kaniko Building

### Prerequisites

- Kubernetes cluster
- Registry credentials configured

### Deploy Kaniko Build Job

```bash
# Update registry information in kaniko-build.yaml
# Then apply the manifest
kubectl apply -f kaniko-build.yaml

# Monitor the build progress
kubectl logs -f job/kaniko-multi-arch-build

# Check build status
kubectl get jobs
```

### Registry Credentials Setup

Create a secret with your registry credentials:

```bash
kubectl create secret docker-registry registry-credentials \
  --docker-server=your-registry.com \
  --docker-username=your-username \
  --docker-password=your-password \
  --docker-email=your-email@example.com
```

## Build Output

The enhanced Dockerfile includes:

1. **Architecture Detection**: Automatically detects and logs the build architecture
2. **Build Information**: Captures build date, platform, and tool versions
3. **Testing Script**: Runs comprehensive tests including:
   - Architecture verification
   - Network connectivity checks
   - File operation tests
   - Tool version checks
4. **Health Checks**: Built-in Docker health check using the test script

## Example Output

When you run the container, you'll see output like:

```
=== Build Test Results ===
Current architecture: x86_64
Platform: Linux
Curl version: curl 8.5.0 (x86_64-alpine-linux-musl)
Wget version: GNU Wget 1.21.4 built on linux-gnu
Testing network connectivity...
✅ Network connectivity: OK
Testing file operations...
✅ File operations: OK
=== Test completed successfully ===
Build Info:
Architecture: x86_64
Platform: Linux
Build Date: Wed Oct 25 10:30:45 UTC 2023
Alpine Version: 3.18.4
Hello from multi-arch build context!
```

## Customization

You can customize the build by:

- Modifying the `IMAGE_NAME` and `TAG` environment variables
- Adding additional tools to the Dockerfile
- Extending the test script with more checks
- Configuring different registry endpoints in the kaniko manifest

## Troubleshooting

- Ensure Docker buildx is installed for local multi-arch builds
- Verify registry credentials are correctly configured for kaniko builds
- Check that your Kubernetes cluster has sufficient resources for the build job

#!/bin/bash

# Test script for multi-architecture Docker builds
set -e

IMAGE_NAME=${IMAGE_NAME:-"test-app"}
TAG=${TAG:-"latest"}
DOCKERFILE=${DOCKERFILE:-"Dockerfile"}

echo "🔧 Testing Docker build for multi-architecture support..."
echo "📁 Using Dockerfile: $DOCKERFILE"

# Function to test build for specific platform
test_build() {
    local platform=$1
    local tag_suffix=$2
    
    echo "📦 Building for platform: $platform"
    docker build --platform $platform -f $DOCKERFILE -t ${IMAGE_NAME}:${TAG}-${tag_suffix} .
    
    echo "🧪 Testing built image for $platform..."
    docker run --rm --platform $platform ${IMAGE_NAME}:${TAG}-${tag_suffix} /app/test-build.sh
    
    echo "✅ Build and test completed for $platform"
    echo "----------------------------------------"
}

# Test local builds
echo "🚀 Starting multi-architecture build tests..."

# Build and test for amd64
test_build "linux/amd64" "amd64"

# Build and test for arm64 (if supported)
if docker buildx version > /dev/null 2>&1; then
    echo "🔨 Docker Buildx detected, testing arm64 build..."
    test_build "linux/arm64" "arm64"
    
    # Create multi-arch manifest
    echo "📋 Creating multi-architecture manifest..."
    docker buildx build --platform linux/amd64,linux/arm64 -f $DOCKERFILE -t ${IMAGE_NAME}:${TAG} . --push=false
    echo "✅ Multi-architecture manifest created successfully"
else
    echo "⚠️  Docker Buildx not available, skipping arm64 build"
fi

echo "🎉 All build tests completed successfully!"

# Show build information
echo "📊 Build Summary:"
echo "  - Image name: ${IMAGE_NAME}"
echo "  - Tag: ${TAG}"
echo "  - Available images:"
docker images | grep ${IMAGE_NAME} || echo "No images found with name ${IMAGE_NAME}"

# Test image inspection
echo "🔍 Image architecture information:"
for tag in amd64 arm64; do
    if docker image inspect ${IMAGE_NAME}:${TAG}-${tag} > /dev/null 2>&1; then
        echo "  ${IMAGE_NAME}:${TAG}-${tag}:"
        docker image inspect ${IMAGE_NAME}:${TAG}-${tag} --format '    Architecture: {{.Architecture}}, OS: {{.Os}}'
    fi
done

echo "✨ Build testing completed!" 
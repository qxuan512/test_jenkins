# Multi-architecture Dockerfile for kaniko builds (amd64/arm64) - Kaniko Compatible
FROM python:3.12-alpine

# The base image already contains Python and pip.
# Install other necessary tools.
RUN apk add --no-cache \
    busybox-suid \
    curl \
    wget \
    jq \
    file \
    bash \
    && rm -rf /var/cache/apk/* /tmp/*

# Create application directory
WORKDIR /app

# Copy requirements.txt first for better Docker layer caching
COPY requirements.txt .

# Install Python dependencies (compatible with kaniko)
RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt

# Add architecture detection and build info
RUN echo "Build Info:" > /app/build-info.txt && \
    echo "Architecture: $(uname -m)" >> /app/build-info.txt && \
    echo "Platform: $(uname -s)" >> /app/build-info.txt && \
    echo "Build Date: $(date)" >> /app/build-info.txt && \
    echo "Alpine Version: $(cat /etc/alpine-release)" >> /app/build-info.txt && \
    echo "Python Version: $(python3 --version)" >> /app/build-info.txt && \
    echo "Pip Version: $(pip3 --version)" >> /app/build-info.txt

# Copy application files
COPY . .

# Add a simple test script
RUN cat > /app/test-build.sh << 'EOF'
#!/bin/bash
echo "=== Build Test Results ==="
echo "Current architecture: $(uname -m)"
echo "Platform: $(uname -s)"
echo "Curl version: $(curl --version | head -1)"
echo "Wget version: $(wget --version | head -1)"
echo "Python version: $(python3 --version)"
echo "Pip version: $(pip3 --version)"
echo "Testing network connectivity..."
if timeout 10 curl -s --connect-timeout 5 https://httpbin.org/get > /dev/null; then
    echo "✅ Network connectivity: OK"
else
    echo "❌ Network connectivity: Failed or timeout"
fi
echo "Testing file operations..."
echo "test" > /tmp/test-file && rm /tmp/test-file
echo "✅ File operations: OK"
echo "Testing Python installation..."
python3 -c "import sys; print(f'✅ Python {sys.version.split()[0]} is working')" 2>/dev/null || echo "❌ Python test failed"
echo "Testing installed packages..."
pip3 list | head -10
echo "=== Test completed successfully ==="
cat /app/build-info.txt
EOF

# Make test script executable
RUN chmod +x /app/test-build.sh

# Add health check with timeout
HEALTHCHECK --interval=30s --timeout=15s --start-period=10s --retries=3 \
    CMD timeout 10 /app/test-build.sh || exit 1

# Set startup command with build test
CMD ["/bin/sh", "-c", "/app/test-build.sh && echo 'Hello from multi-arch build context!' && tail -f /dev/null"] 
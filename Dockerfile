# Ultra-minimal Dockerfile for smallest possible image size
# Using Python 3.12 for better stability and pip compatibility
FROM --platform=$BUILDPLATFORM python:3.12.8-slim-bookworm

# Build arguments
ARG TARGETARCH
ARG TARGETPLATFORM

# Install packages using apt with improved lock handling
RUN set -ex && \
    # Clean any existing locks and wait
    rm -f /var/lib/apt/lists/lock /var/lib/dpkg/lock /var/lib/dpkg/lock-frontend && \
    sleep 2 && \
    # Retry mechanism for apt operations
    for i in 1 2 3; do \
        apt-get update && break || { echo "apt-get update failed, attempt $i/3"; sleep 5; } \
    done && \
    # Install required packages with retry
    for i in 1 2 3; do \
        apt-get install -y --no-install-recommends curl && break || { echo "apt-get install failed, attempt $i/3"; sleep 5; } \
    done && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set working directory
WORKDIR /app

# Update pip and essential tools for better compatibility
RUN python -m pip install --upgrade pip setuptools wheel

# Copy and install Python dependencies with enhanced error handling
COPY requirements.txt ./
RUN python -m pip install --no-cache-dir --no-deps -r requirements.txt || \
    (echo "First attempt failed, trying with individual packages..." && \
     python -m pip install --no-cache-dir pandas numpy requests websocket-client colorama python-dotenv paho-mqtt pyserial python-dateutil jsonschema) \
    && python -m pip cache purge \
    && rm -rf /root/.cache /root/.local /tmp/pip-*

# Copy only essential application files
COPY main.py config.json ./
COPY app.sh ./
COPY driver.py ./

# Set permissions and create minimal directories
RUN chmod +x app.sh \
    && mkdir -p /var/log/iot-driver

# Minimal platform logging
RUN echo "${TARGETARCH:-unknown}" > /app/arch.txt

# Minimal health check
HEALTHCHECK --interval=60s --timeout=5s --retries=2 \
    CMD curl -f http://localhost:8080/health || exit 1

# Expose port
EXPOSE 8080

# Start application
CMD ["./app.sh"] 
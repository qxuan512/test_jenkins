# Ultra-minimal Dockerfile for smallest possible image size
FROM --platform=$BUILDPLATFORM python:3.13.5-alpine

# Build arguments
ARG TARGETARCH
ARG TARGETPLATFORM

# Install packages with retry and random delay for parallel builds
RUN DELAY=$((RANDOM % 5 + 1)) && echo "Starting with ${DELAY}s delay for parallel build safety..." && sleep $DELAY \
    && for i in 1 2 3 4 5; do \
        apk add --no-cache curl && break || \
        (echo "APK install attempt $i failed, retrying in $((i * 2)) seconds..." && sleep $((i * 2))); \
    done \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Set working directory
WORKDIR /app

# Copy and install Python dependencies with parallel build safety
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt \
    && pip cache purge \
    && rm -rf /root/.cache /root/.local /tmp/pip-*

# Copy only essential application files
COPY main.py config.json ./
COPY app.sh ./

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
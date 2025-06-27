# Start from your own trusted, pre-built base image.
# This base image already contains Python and all necessary system dependencies.
FROM python:3.13.5-slim-bookworm

RUN apk add --no-cache busybox-suid && \
    apk add --no-cache \
    curl \
    wget \
    jq \
    file \
    bash \
# Create application directory
WORKDIR /app

# Copy requirements.txt first for better Docker layer caching
COPY requirements.txt .

# Install Python dependencies (compatible with kaniko)
RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt

# Copy and run the build-time test script
COPY run-tests.sh .
RUN chmod +x ./run-tests.sh
RUN ./run-tests.sh

# Copy application files
COPY . .

# Copy the startup script and make it executable
COPY startup.sh /app/startup.sh
RUN chmod +x /app/startup.sh

# Set the command to run the startup script and keep the container alive.
CMD ["/bin/sh", "-c", "/app/startup.sh && echo '--- Container is running. Use `docker exec` to interact. ---' && tail -f /dev/null"] 
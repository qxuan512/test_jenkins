#!/bin/sh
# A simple startup script that runs when the container starts.

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Container Startup Checks ---"

# Example Runtime Check 1: Print Python version
echo "Python version: $(python3 --version)"

# Example Runtime Check 2: Verify a key library can be imported
echo "Verifying 'pandas' installation..."
python3 -c "import pandas; print('✅ Pandas is correctly installed.')"

# Add any other startup tasks here.

echo "--- Startup Checks Passed. Container is ready. ---" 
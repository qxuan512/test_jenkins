#!/bin/bash
# A simple build-time test script

# Set strict error checking
set -e

echo "--- Running Build-Time Tests ---"

# Test 1: Verify Python can import a key library from requirements.txt
echo "Testing: Python can import 'pandas' library..."
python3 -c "import pandas; print('✅ Pandas import successful.')"

# Add more tests here if needed
# For example, checking another library:
# echo "Testing: Python can import 'requests' library..."
# python3 -c "import requests; print('✅ Requests import successful.')"

echo "--- All Build-Time Tests Passed ---" 
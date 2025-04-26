#!/bin/bash
# scripts/check_env.sh

echo "=== NVIDIA-SMI ==="
nvidia-smi

echo -e "\n=== nvcc Version ==="
nvcc --version

echo -e "\n=== Python Packages ==="
python3 - <<EOF
import sys
print("Python:", sys.version.split()[0])
try:
    import matplotlib, numpy
    print("matplotlib:", matplotlib.__version__)
    print("numpy:", numpy.__version__)
except ImportError as e:
    print("Missing package:", e)
EOF

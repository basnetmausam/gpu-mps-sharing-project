#!/bin/bash
# scripts/stop_mps.sh

set -e

echo "Stopping MPS control daemon..."

# Check if /tmp/nvidia-mps/control exists AND is a valid named pipe
if [ -p /tmp/nvidia-mps/control ]; then
    echo "Sending quit to MPS control..."
    echo quit | sudo tee /tmp/nvidia-mps/control
    sleep 1
else
    echo "No valid MPS control pipe found. Skipping quit."
fi

# Kill any remaining MPS processes (safely)
sudo killall -q nvidia-cuda-mps-control || true
sudo killall -q nvidia-cuda-mps-server || true

# Reset GPU back to normal
echo "Resetting GPU to DEFAULT mode..."
sudo nvidia-smi -c DEFAULT

echo "MPS stopped and GPU reset."

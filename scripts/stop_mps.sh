#!/bin/bash
# Stop NVIDIA MPS server

echo "Stopping MPS control daemon..."
echo quit | nvidia-cuda-mps-control
echo "MPS stopped."

# GPU MPS Sharing Project

## Overview
Evaluate NVIDIA MPS for concurrent CUDA workloads (matrix mul, reduction, convolution).

## Prerequisites
- CUDA toolkit (nvcc)
- Python 3
- NVIDIA GPU with MPS support

## Setup
```bash
# 1. Build CUDA programs
make

# 2. Make scripts executable
chmod +x scripts/*.sh scripts/*.py

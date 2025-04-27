#!/bin/bash
# scripts/run_all_mixtures.sh

set -e

echo "==============================="
echo "Running ALL mixture experiments"
echo "==============================="

SRC_DIR="../src"
RESULTS_DIR="../results/mixtures"
MIXTURES=("heavy_heavy" "heavy_light" "memory_heavy" "light_light" "heavy_memory_light")

# ----------------------------------------
# Step 1: Clean Start — Make sure MPS is OFF
./stop_mps.sh

# ----------------------------------------
# Step 2: Run all NO-MPS experiments
echo "==============================="
echo "Running mixtures WITHOUT MPS..."
echo "==============================="

for mixture in "${MIXTURES[@]}"; do
    echo "Running $mixture WITHOUT MPS..."
    ./run_mixture_${mixture}_no_mps.sh
done

# ----------------------------------------
# Step 3: Enable MPS
./start_mps.sh

# ----------------------------------------
# Step 4: Run all WITH-MPS experiments
echo "==============================="
echo "Running mixtures WITH MPS..."
echo "==============================="

for mixture in "${MIXTURES[@]}"; do
    echo "Running $mixture WITH MPS..."
    ./run_mixture_${mixture}_mps.sh
done

# ----------------------------------------
# Step 5: Clean shutdown
./stop_mps.sh

echo "==============================="
echo "All mixture experiments completed!"
echo "==============================="

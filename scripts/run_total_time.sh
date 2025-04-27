#!/bin/bash
# srun_experiments.sh

set -e  # Exit immediately if any command fails

# Paths
SRC_DIR="../src"
RESULTS_DIR="../results"
MPS_DISABLED_DIR="$RESULTS_DIR/mps_disabled"
MPS_ENABLED_DIR="$RESULTS_DIR/mps_enabled"
PROGRAMS=("matrix_mul" "memory_copy" "vector_add" "image_convolution" "prefix_sum" "fft")

# Create results folders if they don't exist
mkdir -p "$MPS_DISABLED_DIR"
mkdir -p "$MPS_ENABLED_DIR"

# ===============================================
# Ensure clean start: stop any previous MPS
bash stop_mps.sh

# ===============================================
# Run programs sequentially (WITHOUT MPS)
echo "==============================="
echo "Running programs WITHOUT MPS..."
echo "==============================="

total_start_no_mps=$(date +%s.%N)

for prog in "${PROGRAMS[@]}"; do
    echo "Running $prog without MPS..."
    start_time=$(date +%s.%N)
    $SRC_DIR/$prog > "$MPS_DISABLED_DIR/${prog}_no_mps.log" 2>&1
    end_time=$(date +%s.%N)
    runtime=$(echo "$end_time - $start_time" | bc)
    echo "Execution Time: $runtime seconds" >> "$MPS_DISABLED_DIR/${prog}_no_mps.log"
done

total_end_no_mps=$(date +%s.%N)
total_runtime_no_mps=$(echo "$total_end_no_mps - $total_start_no_mps" | bc)

echo "Total Wall Time without MPS: $total_runtime_no_mps seconds"
echo "$total_runtime_no_mps" > "$RESULTS_DIR/total_no_mps_time.txt"

# ===============================================
# Start MPS
bash start_mps.sh

# ===============================================
# Run programs concurrently (WITH MPS)
echo "==============================="
echo "Running programs WITH MPS..."
echo "==============================="

total_start_mps=$(date +%s.%N)

for prog in "${PROGRAMS[@]}"; do
    (
        echo "Running $prog with MPS..."
        start_time=$(date +%s.%N)
        $SRC_DIR/$prog > "$MPS_ENABLED_DIR/${prog}_mps.log" 2>&1
        end_time=$(date +%s.%N)
        runtime=$(echo "$end_time - $start_time" | bc)
        echo "Execution Time: $runtime seconds" >> "$MPS_ENABLED_DIR/${prog}_mps.log"
    ) &
done

wait

total_end_mps=$(date +%s.%N)
total_runtime_mps=$(echo "$total_end_mps - $total_start_mps" | bc)

echo "Total Wall Time with MPS: $total_runtime_mps seconds"
echo "$total_runtime_mps" > "$RESULTS_DIR/total_mps_time.txt"

# ===============================================
# Stop MPS
bash stop_mps.sh

echo "==============================="
echo "All experiments completed!"
echo "==============================="

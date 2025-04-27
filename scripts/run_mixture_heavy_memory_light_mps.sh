#!/bin/bash
# heavy-memory-light mixture with MPS

set -e

SRC_DIR="../src"
RESULTS_DIR="../results/mixtures/heavy_memory_light/mps"
mkdir -p "$RESULTS_DIR"

./stop_mps.sh
./start_mps.sh

start_total=$(date +%s.%N)

(
    $SRC_DIR/matrix_mul > "$RESULTS_DIR/matrix_mul.log" 2>&1
) &
(
    $SRC_DIR/memory_copy > "$RESULTS_DIR/memory_copy.log" 2>&1
) &
(
    $SRC_DIR/vector_add > "$RESULTS_DIR/vector_add.log" 2>&1
) &

wait

end_total=$(date +%s.%N)
runtime_total=$(echo "$end_total - $start_total" | bc)

echo "$runtime_total" > "$RESULTS_DIR/total_time.txt"

./stop_mps.sh

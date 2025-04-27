#!/bin/bash

set -e

SRC_DIR="../src"
RESULTS_DIR="../results/mixtures/light_heavy/no_mps"
mkdir -p "$RESULTS_DIR"

start_total=$(date +%s.%N)

(
    $SRC_DIR/vector_add > "$RESULTS_DIR/vector_add.log" 2>&1
) &
(
    $SRC_DIR/matrix_mul > "$RESULTS_DIR/matrix_mul.log" 2>&1
) &

wait

end_total=$(date +%s.%N)
runtime_total=$(echo "$end_total - $start_total" | bc)

echo "$runtime_total" > "$RESULTS_DIR/total_time.txt"

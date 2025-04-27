#!/bin/bash
# heavy-heavy mixture without MPS

set -e

SRC_DIR="../src"
RESULTS_DIR="../results/mixtures/heavy_heavy/no_mps"
mkdir -p "$RESULTS_DIR"

./stop_mps.sh

start_total=$(date +%s.%N)

(
    $SRC_DIR/matrix_mul > "$RESULTS_DIR/matrix_mul.log" 2>&1
) &
(
    $SRC_DIR/fft > "$RESULTS_DIR/fft.log" 2>&1
) &

wait

end_total=$(date +%s.%N)
runtime_total=$(echo "$end_total - $start_total" | bc)

echo "$runtime_total" > "$RESULTS_DIR/total_time.txt"

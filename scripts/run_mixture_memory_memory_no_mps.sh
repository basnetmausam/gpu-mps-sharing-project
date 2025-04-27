#!/bin/bash

set -e

SRC_DIR="../src"
RESULTS_DIR="../results/mixtures/memory_memory/no_mps"
mkdir -p "$RESULTS_DIR"

start_total=$(date +%s.%N)

(
    $SRC_DIR/memory_copy > "$RESULTS_DIR/memory_copy.log" 2>&1
) &
(
    $SRC_DIR/prefix_sum > "$RESULTS_DIR/prefix_sum.log" 2>&1
) &

wait

end_total=$(date +%s.%N)
runtime_total=$(echo "$end_total - $start_total" | bc)

echo "$runtime_total" > "$RESULTS_DIR/total_time.txt"

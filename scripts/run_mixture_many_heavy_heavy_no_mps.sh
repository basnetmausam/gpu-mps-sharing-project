#!/bin/bash
# run_mixture_many_heavy_heavy_no_mps.sh

set -e

SRC_DIR="../src"
RESULTS_DIR="../results/mixtures/many_heavy_heavy/no_mps"
mkdir -p "$RESULTS_DIR"

start_total=$(date +%s.%N)

# Launch 24 matrix_mul concurrently
for i in {1..24}; do
    $SRC_DIR/matrix_mul > "$RESULTS_DIR/matrix_mul_$i.log" 2>&1 &
done

wait

end_total=$(date +%s.%N)
runtime_total=$(echo "$end_total - $start_total" | bc)

echo "$runtime_total" > "$RESULTS_DIR/total_time.txt"

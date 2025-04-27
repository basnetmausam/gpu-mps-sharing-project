#!/bin/bash

set -e

SRC_DIR="../src"
RESULTS_DIR="../results/mixtures/many_light_light/mps"
mkdir -p "$RESULTS_DIR"

start_total=$(date +%s.%N)

# Launch 8 vector_add
for i in {1..8}; do
    $SRC_DIR/vector_add > "$RESULTS_DIR/vector_add_$i.log" 2>&1 &
done

# Launch 8 image_convolution
for i in {1..8}; do
    $SRC_DIR/image_convolution > "$RESULTS_DIR/image_convolution_$i.log" 2>&1 &
done

wait

end_total=$(date +%s.%N)
runtime_total=$(echo "$end_total - $start_total" | bc)

echo "$runtime_total" > "$RESULTS_DIR/total_time.txt"

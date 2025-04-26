#!/bin/bash
# scripts/run_experiments.sh
set -e

ROOT=$(dirname "$(dirname "$0")")
SRC=$ROOT/src
RESULTS=$ROOT/results

# Ensure results dirs exist
mkdir -p "$RESULTS"/{sequential,no_mps,mps}/{runtime_logs,nvidia_smi_logs,profiler_output}

# 1) Sequential runs
echo "=== Sequential Runs ==="
for prog in matrix_mul vector_reduction image_convolution; do
  LOG="$RESULTS/sequential/runtime_logs/${prog}.log"
  echo "--- $prog ---" | tee "$LOG"
  bash scripts/run_single.sh "$prog" 2>&1 | tee -a "$LOG"
done

# 2) Concurrent without MPS
echo "=== Concurrent without MPS ==="
pushd "$SRC" > /dev/null
python3 ../scripts/run_concurrent.py 2>&1 | tee "../$RESULTS/no_mps/runtime_logs/concurrent.log"
popd > /dev/null

# 3) Concurrent with MPS
echo "=== Starting MPS ==="
bash scripts/start_mps.sh

echo "=== Concurrent with MPS ==="
pushd "$SRC" > /dev/null
python3 ../scripts/run_concurrent.py 2>&1 | tee "../$RESULTS/mps/runtime_logs/concurrent.log"
popd > /dev/null

echo "=== Stopping MPS ==="
bash scripts/stop_mps.sh

echo "All experiments done."

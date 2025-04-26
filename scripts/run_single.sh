#!/bin/bash
# Run a single CUDA program sequentially
# Usage: ./run_single.sh <program_name_without_extension>

if [ -z "$1" ]; then
    echo "Usage: $0 <program_name_without_extension>"
    exit 1
fi

PROGRAM=$1
SRC_DIR="../src"
BIN="${SRC_DIR}/${PROGRAM}.out"

# Compile
echo "Compiling ${PROGRAM}.cu..."
nvcc "${SRC_DIR}/${PROGRAM}.cu" -o "${BIN}" || exit 1

# Run
echo "Running ${BIN}..."
"${BIN}"

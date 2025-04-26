#!/usr/bin/env python3
import subprocess

# List of program names (without extension)
programs = ["matrix_mul", "vector_reduction", "image_convolution"]
src_dir = "../src"

# Compile all programs
for prog in programs:
    src_file = f"{src_dir}/{prog}.cu"
    out_file = f"{src_dir}/{prog}.out"
    print(f"Compiling {src_file}...")
    subprocess.run(["nvcc", src_file, "-o", out_file], check=True)

# Launch programs concurrently
processes = []
print("Launching concurrent CUDA programs...")
for prog in programs:
    out_file = f"{src_dir}/{prog}.out"
    p = subprocess.Popen([out_file], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    processes.append((prog, p))

# Wait for completion and log outputs
for prog, p in processes:
    out, err = p.communicate()
    print(f"== {prog} Output ==")
    print(out.decode())
    if err:
        print(err.decode())
print("All concurrent executions finished.")

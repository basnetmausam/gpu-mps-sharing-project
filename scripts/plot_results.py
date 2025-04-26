#!/usr/bin/env python3
import os
import matplotlib.pyplot as plt

# Define paths
BASE = os.path.join("results")
modes = ["sequential", "no_mps", "mps"]
programs = ["matrix_mul", "vector_reduction", "image_convolution"]

# TODO: parse runtime_logs/{prog}.log or profiler CSVs into data structures

def plot_runtimes():
    # dummy example
    times = {
        "sequential": [100, 200, 150],
        "no_mps":     [120, 220, 170],
        "mps":        [110, 210, 160]
    }
    for mode in modes:
        plt.plot(programs, times[mode], marker='o', label=mode)
    plt.xlabel("Workload")
    plt.ylabel("Time (ms)")
    plt.legend()
    plt.tight_layout()
    plt.savefig("plots/runtime_comparison.png")
    plt.show()

if __name__ == "__main__":
    plot_runtimes()

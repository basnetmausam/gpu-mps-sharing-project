# scripts/plot_results.py

import os
import matplotlib.pyplot as plt

# ----------------------------
# Paths
RESULTS_DIR = "../results"
PLOTS_DIR = "../plots"

# Mixture list
MIXTURES = ["heavy_heavy", "heavy_light", "memory_heavy", "light_light", "heavy_memory_light"]

# ----------------------------
# Helper functions

def read_time(filepath):
    with open(filepath, 'r') as f:
        return float(f.readline().strip())

def plot_total_system_time():
    """Plot total system time for original CUDA experiments"""
    no_mps_path = os.path.join(RESULTS_DIR, "total_no_mps_time.txt")
    mps_path = os.path.join(RESULTS_DIR, "total_mps_time.txt")

    if not os.path.exists(no_mps_path) or not os.path.exists(mps_path):
        print("[!] Skipping original CUDA experiment plot - files not found.")
        return

    total_no_mps = read_time(no_mps_path)
    total_mps = read_time(mps_path)
    speedup = total_no_mps / total_mps if total_mps != 0 else 0

    print("\n=== Original CUDA Programs ===")
    print(f"Total Wall Time WITHOUT MPS: {total_no_mps:.4f} seconds")
    print(f"Total Wall Time WITH MPS   : {total_mps:.4f} seconds")
    print(f"Speedup: {speedup:.2f}x")

    # Plot
    plt.figure(figsize=(8,6))
    bars = plt.bar(["Without MPS", "With MPS"], [total_no_mps, total_mps], 
                   color=["red", "green"], alpha=0.7)

    # Annotations
    for bar, val in zip(bars, [total_no_mps, total_mps]):
        plt.text(bar.get_x() + bar.get_width()/2, val * 1.01,
                 f"{val:.3f}s", ha='center', va='bottom', fontsize=11)

    plt.ylabel("Total Wall Time (seconds)", fontsize=13)
    plt.title("Total System Wall Time: CUDA Programs (MPS vs Non-MPS)", fontsize=15)
    plt.grid(axis='y', linestyle='--', alpha=0.6)
    plt.text(0.5, max(total_no_mps, total_mps) * 1.2,
             f"Speedup: {speedup:.2f}x", ha='center', fontsize=12, color='blue')
    plt.tight_layout()

    os.makedirs(PLOTS_DIR, exist_ok=True)
    save_path = os.path.join(PLOTS_DIR, "original_total_system_time.png")
    plt.savefig(save_path)
    print(f"Original CUDA experiment plot saved to {save_path}")

    plt.show()

def plot_mixture_system_times():
    """Plot total system time for different workload mixtures"""
    no_mps_times = []
    mps_times = []
    speedups = []

    for mixture in MIXTURES:
        no_mps_path = os.path.join(RESULTS_DIR, "mixtures", mixture, "no_mps", "total_time.txt")
        mps_path = os.path.join(RESULTS_DIR, "mixtures", mixture, "mps", "total_time.txt")

        if os.path.exists(no_mps_path) and os.path.exists(mps_path):
            no_mps_time = read_time(no_mps_path)
            mps_time = read_time(mps_path)

            no_mps_times.append(no_mps_time)
            mps_times.append(mps_time)
            speedups.append(no_mps_time / mps_time if mps_time != 0 else 0)
        else:
            print(f"[!] Warning: Missing data for {mixture}")
            no_mps_times.append(0)
            mps_times.append(0)
            speedups.append(0)

    print("\n=== Mixture Experiments ===")
    for mixture, no_mps_time, mps_time, speedup in zip(MIXTURES, no_mps_times, mps_times, speedups):
        print(f"{mixture}:")
        print(f"  - WITHOUT MPS: {no_mps_time:.4f} seconds")
        print(f"  - WITH MPS   : {mps_time:.4f} seconds")
        print(f"  - Speedup    : {speedup:.2f}x\n")

    x = range(len(MIXTURES))
    width = 0.35

    plt.figure(figsize=(12, 7))
    plt.bar([i - width/2 for i in x], no_mps_times, width=width, label="Without MPS", color='red', alpha=0.7)
    plt.bar([i + width/2 for i in x], mps_times, width=width, label="With MPS", color='green', alpha=0.7)

    # Annotations
    for i, (no_mps, mps, speedup) in enumerate(zip(no_mps_times, mps_times, speedups)):
        plt.text(i - width/2, no_mps * 1.01, f"{no_mps:.2f}s", ha='center', va='bottom', fontsize=9)
        plt.text(i + width/2, mps * 1.01, f"{mps:.2f}s", ha='center', va='bottom', fontsize=9)
        plt.text(i, max(no_mps, mps) * 1.1, f"{speedup:.2f}x", ha='center', va='bottom', fontsize=10, color='blue')

    plt.xticks(x, MIXTURES, rotation=45, ha='right', fontsize=11)
    plt.ylabel("Total Wall Time (seconds)", fontsize=13)
    plt.title("Total System Wall Time: Different Mixtures (MPS vs Non-MPS)", fontsize=15)
    plt.legend()
    plt.grid(axis='y', linestyle='--', alpha=0.6)
    plt.tight_layout()

    os.makedirs(PLOTS_DIR, exist_ok=True)
    save_path = os.path.join(PLOTS_DIR, "mixtures_total_system_time.png")
    plt.savefig(save_path)
    print(f"Mixtures experiment plot saved to {save_path}")

    plt.show()

# ----------------------------
# Main
if __name__ == "__main__":
    plot_total_system_time()
    plot_mixture_system_times()

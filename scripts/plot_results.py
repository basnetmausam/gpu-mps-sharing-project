import os
import matplotlib.pyplot as plt

# Paths
RESULTS_DIR = "../results/mixtures"
PLOTS_DIR = "../plots"
os.makedirs(PLOTS_DIR, exist_ok=True)

# Mixture categories
light_workloads = ["light_light"]
heavy_workloads = ["heavy_heavy", "memory_compute", "memory_memory"]

# Final overview = light + heavy
all_workloads = [
    "light_light",
    "heavy_heavy",
    "memory_compute",
    "memory_memory"
]

# Mixture descriptive labels
MIXTURE_LABELS = {
    "light_light": "Light (24 × vector_add)",
    "heavy_heavy": "Heavy (matrix_mul + fft)",
    "memory_compute": "Memory + Compute (memory_copy + matrix_mul)",
    "memory_memory": "Memory (memory_copy + prefix_sum)",
}

# Helper function to read times
def read_total_time(mixture, mode):
    path = os.path.join(RESULTS_DIR, mixture, mode, "total_time.txt")
    if not os.path.exists(path):
        return None
    with open(path, "r") as f:
        return float(f.read().strip())

# Professional color palette
colors = {
    "no_mps": "#1f77b4",   # soft blue
    "mps": "#ff7f0e"       # soft orange
}

# Function to plot a category
def plot_mixtures(mixtures, title, filename):
    no_mps_times = []
    mps_times = []
    speedups = []

    for mixture in mixtures:
        no_mps_time = read_total_time(mixture, "no_mps")
        mps_time = read_total_time(mixture, "mps")
        no_mps_times.append(no_mps_time)
        mps_times.append(mps_time)
        speedups.append(no_mps_time / mps_time if mps_time else 0)

    x = range(len(mixtures))
    width = 0.35

    fig, ax = plt.subplots(figsize=(10, 6))

    # Bars
    ax.bar([i - width/2 for i in x], no_mps_times, width=width, label="Without MPS", color=colors["no_mps"], edgecolor='black')
    ax.bar([i + width/2 for i in x], mps_times, width=width, label="With MPS", color=colors["mps"], edgecolor='black')

    # Labels and titles
    ax.set_xticks(x)
    ax.set_xticklabels([MIXTURE_LABELS[mix] for mix in mixtures], rotation=30, ha='right', fontsize=11)
    ax.set_xlabel("Workload Type", fontsize=14)
    ax.set_ylabel("Total Wall Time (seconds)", fontsize=14)
    ax.set_title(title, fontsize=16, fontweight='bold')

    # Gridlines
    ax.grid(axis='y', linestyle='--', alpha=0.7)

    # Axis thickness
    ax.spines['top'].set_linewidth(1.5)
    ax.spines['right'].set_linewidth(1.5)
    ax.spines['left'].set_linewidth(1.5)
    ax.spines['bottom'].set_linewidth(1.5)

    # Legend
    ax.legend(fontsize=12, loc='upper right')

    plt.tight_layout()
    plt.savefig(os.path.join(PLOTS_DIR, filename), dpi=300)
    plt.close()

    print(f"{title} plot saved to {PLOTS_DIR}/{filename}")

# === Plot each category ===

print("\n=== Light Workloads ===")
plot_mixtures(light_workloads, "Light Workloads: MPS vs No MPS", "light_workloads.png")

print("\n=== Heavy Workloads ===")
plot_mixtures(heavy_workloads, "Heavy Workloads: MPS vs No MPS", "heavy_workloads.png")

print("\n=== All Mixtures Overview ===")
plot_mixtures(all_workloads, "All Mixtures Overview: MPS vs No MPS", "all_mixtures_overview.png")

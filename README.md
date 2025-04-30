# MPS in Action: Analyzing GPU Concurrency for Light, Heavy, and Memory-Bound Kernels

This repository contains all source code, scripts, experiment data, and plots from our report:

**MPS in Action: Analyzing GPU Concurrency for Light, Heavy, and Memory-Bound Kernels**  
Authors: Mausam Basnet, Arun Kunwar, Samip Pokhrel  
Affiliation: University of North Texas, 2025

## 📄 Abstract

NVIDIA’s Multi-Process Service (MPS) offers fine-grained GPU resource sharing by enabling concurrent kernel execution across processes. This project systematically evaluates the performance of MPS under various CUDA workloads — light, heavy, memory-bound, and saturated scenarios. Our experiments uncover when MPS improves GPU throughput and when it may introduce unnecessary overhead.


## ⚙️ Requirements

- GPU: NVIDIA T1000 or compatible CUDA GPU
- CUDA Toolkit: 12.8
- NVIDIA Driver: 570.124.06
- OS: Rocky Linux 8.8 (64-bit)
- Python Packages:
  - `pynvml`
  - `matplotlib`
  - `pandas`

## 🚀 How to Run the Project

1. **Compile CUDA Kernels**
   ```bash
   cd <project_directory>
   make
   ```

2. **Run Total Time Experiments**
   ```bash
   cd scripts
   bash run_total_time.sh
   ```

3. **Run All Mixture Experiments**
   ```bash
   bash run_all_mixtures.sh
   ```

4. **Generate Plot Visualizations**
   ```bash
   cd ..
   python3 plot_graph.py
   ```

## ⚠️ MPS Setup Instructions

Before running MPS experiments:

- Kill any existing MPS daemons:
  ```bash
  pkill -f nvidia-cuda-mps-control
  ```

- Set GPU to `EXCLUSIVE_PROCESS` mode:
  ```bash
  sudo nvidia-smi -c EXCLUSIVE_PROCESS
  ```

- Start MPS server (if needed):
  ```bash
  sudo nvidia-cuda-mps-control -d
  ```

## 📊 Workloads Tested

The following CUDA workloads were tested individually and in combinations:

- `vector_add.cu` – Lightweight compute-bound
- `image_convolution.cu` – Lightweight memory-bound
- `matrix_mul.cu` – Heavyweight compute-bound
- `fft.cu` – Memory-intensive
- `memory_copy.cu` – Memory bandwidth stress
- `prefix_sum.cu` – Balanced memory & compute

Workload mixtures:

- Light-Light  
- Heavy-Heavy  
- Memory-Compute  
- Memory-Memory  
- Saturated-Light (24 vector_add instances)  
- Saturated-Heavy (24 matrix_mul instances)

## 📈 Key Results Summary

- Up to **40% performance gain** in light workloads with high concurrency.
- **25–30% improvement** in mixed compute-heavy and memory-bound workloads.
- Only **5–10% improvement** in saturated-heavy workloads due to resource contention.

## 🧠 Practical Recommendations

- ✅ Use MPS for workloads with **short/light kernels** — significant latency reduction.
- ✅ Use MPS for **mixed memory and compute** workloads — balanced resource usage.
- ⚠️ Be cautious with **saturated heavy workloads** — benefits may be negligible.

## 🧪 Reproducibility

This project is fully reproducible. Follow the setup steps, execute the provided scripts, and plots will be generated using real benchmark logs.

For questions or issues, contact:
- Mausam Basnet: `mausambasnet@my.unt.edu`
- Arun Kunwar: `arunkunwar@my.unt.edu`
- Samip Pokhrel: `samippokhrel@my.unt.edu`


## 🔗 Resources

- 📑 Report PDF: [`architecture_project.pdf`](./architecture_project.pdf)

 
## 📜 License

This project is licensed under the **MIT License**. Feel free to use, modify, and distribute with appropriate credit.

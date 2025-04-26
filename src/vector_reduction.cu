// src/vector_reduction.cu
#include "common_utils.cuh"
#include <iostream>
#include <cstdlib>

static const int N = 1 << 20; // 1 million elements

// Kernel: each thread loads two elements, reduces into shared memory
__global__ void reduceKernel(const float* input, float* output, int n) {
    extern __shared__ float sdata[];
    unsigned int tid = threadIdx.x;
    unsigned int idx = blockIdx.x * (blockDim.x * 2) + threadIdx.x;

    // Load and sum two elements per thread
    float sum = 0.0f;
    if (idx < n)                    sum = input[idx];
    if (idx + blockDim.x < n) sum += input[idx + blockDim.x];
    sdata[tid] = sum;
    __syncthreads();

    // Reduction in shared memory
    for (unsigned int s = blockDim.x / 2; s > 0; s >>= 1) {
        if (tid < s) {
            sdata[tid] += sdata[tid + s];
        }
        __syncthreads();
    }

    // Write per‐block result
    if (tid == 0) output[blockIdx.x] = sdata[0];
}

int main() {
    const int threads = 256;
    const int blocks  = (N + threads * 2 - 1) / (threads * 2);
    size_t   bytes   = N * sizeof(float);
    size_t   outBytes= blocks * sizeof(float);

    // Host allocations
    float* h_in  = (float*)malloc(bytes);
    float* h_out = (float*)malloc(outBytes);

    // Initialize input
    for (int i = 0; i < N; ++i) {
        h_in[i] = 1.0f;  // so the final sum should equal N
    }

    // Device allocations
    float *d_in, *d_out;
    CUDA_CHECK(cudaMalloc(&d_in,  bytes));
    CUDA_CHECK(cudaMalloc(&d_out, outBytes));

    // Copy data to device
    CUDA_CHECK(cudaMemcpy(d_in, h_in, bytes, cudaMemcpyHostToDevice));

    // Timing setup
    cudaEvent_t start, stop;
    CUDA_CHECK(cudaEventCreate(&start));
    CUDA_CHECK(cudaEventCreate(&stop));
    CUDA_CHECK(cudaEventRecord(start));

    // Launch reduction kernel
    reduceKernel<<<blocks, threads, threads * sizeof(float)>>>(d_in, d_out, N);

    // Stop timing
    CUDA_CHECK(cudaEventRecord(stop));
    CUDA_CHECK(cudaEventSynchronize(stop));
    float ms = 0.0f;
    CUDA_CHECK(cudaEventElapsedTime(&ms, start, stop));
    std::cout << "Reduction kernel time: " << ms << " ms\n";

    // Copy partial sums back and finalize on host
    CUDA_CHECK(cudaMemcpy(h_out, d_out, outBytes, cudaMemcpyDeviceToHost));
    float total = 0.0f;
    for (int i = 0; i < blocks; ++i) total += h_out[i];
    std::cout << "Final sum: " << total << std::endl;

    // Cleanup
    CUDA_CHECK(cudaFree(d_in));
    CUDA_CHECK(cudaFree(d_out));
    free(h_in);
    free(h_out);

    return 0;
}

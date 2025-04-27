#include <stdio.h>
#include "common_utils.cuh"

#define N 1024  // MUCH smaller (safe for shared memory)
#define BLOCK_SIZE 256

__global__ void prefixSumKernel(float *input, float *output) {
    __shared__ float temp[N];  // ok now because N=1024

    int tid = threadIdx.x + blockIdx.x * blockDim.x;

    if (tid < N) {
        temp[tid] = input[tid];
    }
    __syncthreads();

    for (int offset = 1; offset < N; offset *= 2) {
        float t = 0;
        if (tid >= offset) {
            t = temp[tid - offset];
        }
        __syncthreads();
        if (tid < N) {
            temp[tid] += t;
        }
        __syncthreads();
    }

    if (tid < N) {
        output[tid] = temp[tid];
    }
}

int main() {
    float *h_input, *h_output;
    CUDA_CHECK(cudaMallocHost(&h_input, N * sizeof(float)));
    CUDA_CHECK(cudaMallocHost(&h_output, N * sizeof(float)));

    for (int i = 0; i < N; i++) {
        h_input[i] = 1.0f;
    }

    float *d_input, *d_output;
    CUDA_CHECK(cudaMalloc(&d_input, N * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&d_output, N * sizeof(float)));

    CUDA_CHECK(cudaMemcpy(d_input, h_input, N * sizeof(float), cudaMemcpyHostToDevice));

    int numBlocks = (N + BLOCK_SIZE - 1) / BLOCK_SIZE;
    prefixSumKernel<<<numBlocks, BLOCK_SIZE>>>(d_input, d_output);
    CUDA_KERNEL_CHECK();

    CUDA_CHECK(cudaMemcpy(h_output, d_output, N * sizeof(float), cudaMemcpyDeviceToHost));

    printf("[prefix_sum] Prefix sum completed successfully.\n");

    CUDA_CHECK(cudaFree(d_input));
    CUDA_CHECK(cudaFree(d_output));
    CUDA_CHECK(cudaFreeHost(h_input));
    CUDA_CHECK(cudaFreeHost(h_output));
    return 0;
}

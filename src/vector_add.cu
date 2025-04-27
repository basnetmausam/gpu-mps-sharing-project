#include <stdio.h>
#include "common_utils.cuh"

#define N (1 << 20)

__global__ void vectorAddKernel(float *A, float *B, float *C) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < N)
        C[idx] = A[idx] + B[idx];
}

int main() {
    float *h_A, *h_B, *h_C;
    CUDA_CHECK(cudaMallocHost(&h_A, N * sizeof(float)));
    CUDA_CHECK(cudaMallocHost(&h_B, N * sizeof(float)));
    CUDA_CHECK(cudaMallocHost(&h_C, N * sizeof(float)));

    for (int i = 0; i < N; i++) {
        h_A[i] = 1.0f;
        h_B[i] = 2.0f;
    }

    float *d_A, *d_B, *d_C;
    CUDA_CHECK(cudaMalloc(&d_A, N * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&d_B, N * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&d_C, N * sizeof(float)));

    CUDA_CHECK(cudaMemcpy(d_A, h_A, N * sizeof(float), cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(d_B, h_B, N * sizeof(float), cudaMemcpyHostToDevice));

    vectorAddKernel<<<(N + 255) / 256, 256>>>(d_A, d_B, d_C);
    CUDA_KERNEL_CHECK();

    CUDA_CHECK(cudaMemcpy(h_C, d_C, N * sizeof(float), cudaMemcpyDeviceToHost));

    printf("[vector_add] Vector addition completed successfully.\n");

    CUDA_CHECK(cudaFree(d_A));
    CUDA_CHECK(cudaFree(d_B));
    CUDA_CHECK(cudaFree(d_C));
    CUDA_CHECK(cudaFreeHost(h_A));
    CUDA_CHECK(cudaFreeHost(h_B));
    CUDA_CHECK(cudaFreeHost(h_C));
    return 0;
}

#include <stdio.h>
#include "common_utils.cuh"

#define SIZE (1 << 26) // ~64MB

int main() {
    float *h_data, *d_data;
    CUDA_CHECK(cudaMallocHost(&h_data, SIZE * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&d_data, SIZE * sizeof(float)));

    for (int i = 0; i < SIZE; i++) {
        h_data[i] = 1.0f;
    }

    CUDA_CHECK(cudaMemcpy(d_data, h_data, SIZE * sizeof(float), cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(h_data, d_data, SIZE * sizeof(float), cudaMemcpyDeviceToHost));

    printf("[memory_copy] Host-Device-Host memory copy completed successfully.\n");

    CUDA_CHECK(cudaFree(d_data));
    CUDA_CHECK(cudaFreeHost(h_data));
    return 0;
}

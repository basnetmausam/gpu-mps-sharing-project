#include <stdio.h>
#include "common_utils.cuh"

#define WIDTH 1024
#define HEIGHT 1024

__global__ void convolution2D(float *input, float *output, float *mask) {
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;

    if (row < HEIGHT && col < WIDTH) {
        float sum = 0.0f;
        for (int i = -1; i <= 1; i++) {
            for (int j = -1; j <= 1; j++) {
                int r = row + i;
                int c = col + j;
                if (r >= 0 && r < HEIGHT && c >= 0 && c < WIDTH) {
                    sum += input[r * WIDTH + c] * mask[(i+1)*3 + (j+1)];
                }
            }
        }
        output[row * WIDTH + col] = sum;
    }
}

int main() {
    size_t bytes = WIDTH * HEIGHT * sizeof(float);
    float *h_input, *h_output, *h_mask;
    CUDA_CHECK(cudaMallocHost(&h_input, bytes));
    CUDA_CHECK(cudaMallocHost(&h_output, bytes));
    CUDA_CHECK(cudaMallocHost(&h_mask, 9 * sizeof(float)));

    for (int i = 0; i < WIDTH * HEIGHT; i++) {
        h_input[i] = 1.0f;
    }
    for (int i = 0; i < 9; i++) {
        h_mask[i] = 1.0f / 9.0f;
    }

    float *d_input, *d_output, *d_mask;
    CUDA_CHECK(cudaMalloc(&d_input, bytes));
    CUDA_CHECK(cudaMalloc(&d_output, bytes));
    CUDA_CHECK(cudaMalloc(&d_mask, 9 * sizeof(float)));

    CUDA_CHECK(cudaMemcpy(d_input, h_input, bytes, cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(d_mask, h_mask, 9 * sizeof(float), cudaMemcpyHostToDevice));

    dim3 threads(16, 16);
    dim3 blocks((WIDTH + threads.x - 1) / threads.x, (HEIGHT + threads.y - 1) / threads.y);

    convolution2D<<<blocks, threads>>>(d_input, d_output, d_mask);
    CUDA_KERNEL_CHECK();

    CUDA_CHECK(cudaMemcpy(h_output, d_output, bytes, cudaMemcpyDeviceToHost));

    printf("[image_convolution] Image convolution completed successfully.\n");

    CUDA_CHECK(cudaFree(d_input));
    CUDA_CHECK(cudaFree(d_output));
    CUDA_CHECK(cudaFree(d_mask));
    CUDA_CHECK(cudaFreeHost(h_input));
    CUDA_CHECK(cudaFreeHost(h_output));
    CUDA_CHECK(cudaFreeHost(h_mask));
    return 0;
}

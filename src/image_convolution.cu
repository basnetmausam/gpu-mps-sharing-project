// src/image_convolution.cu
#include "common_utils.cuh"
#include <iostream>
#include <cstdlib>

static const int WIDTH  = 1024;
static const int HEIGHT = 1024;
static const int KSIZE  = 3;

// Kernel with a small fixed-size convolution filter loaded into constant memory
__constant__ float d_kernel[KSIZE * KSIZE];

__global__ void convolutionKernel(const float* input, float* output, int width, int height) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    if (x >= width || y >= height) return;

    float sum = 0.0f;
    int half = KSIZE / 2;
    for (int ky = -half; ky <= half; ++ky) {
        for (int kx = -half; kx <= half; ++kx) {
            int ix = min(max(x + kx, 0), width - 1);
            int iy = min(max(y + ky, 0), height - 1);
            sum += input[iy * width + ix]
                 * d_kernel[(ky + half) * KSIZE + (kx + half)];
        }
    }
    output[y * width + x] = sum;
}

int main() {
    size_t bytes = WIDTH * HEIGHT * sizeof(float);

    // Allocate host memory
    float *h_in  = (float*)malloc(bytes);
    float *h_out = (float*)malloc(bytes);

    // Initialize input with random values
    for (int i = 0; i < WIDTH * HEIGHT; ++i) {
        h_in[i] = static_cast<float>(rand()) / RAND_MAX;
    }

    // Define a simple 3x3 Gaussian blur kernel on host
    float h_kernel[KSIZE * KSIZE] = {
        1, 2, 1,
        2, 4, 2,
        1, 2, 1
    };
    // Normalize the kernel
    float norm = 0.0f;
    for (int i = 0; i < KSIZE * KSIZE; ++i) norm += h_kernel[i];
    for (int i = 0; i < KSIZE * KSIZE; ++i) h_kernel[i] /= norm;

    // Allocate device memory
    float *d_in, *d_out;
    CUDA_CHECK(cudaMalloc(&d_in,  bytes));
    CUDA_CHECK(cudaMalloc(&d_out, bytes));

    // Copy input image and kernel to GPU
    CUDA_CHECK(cudaMemcpy(d_in, h_in, bytes, cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpyToSymbol(d_kernel, h_kernel, sizeof(h_kernel)));

    // Configure launch parameters
    dim3 threads(16, 16);
    dim3 blocks((WIDTH  + threads.x - 1) / threads.x,
                (HEIGHT + threads.y - 1) / threads.y);

    // Launch and time the kernel
    cudaEvent_t start, stop;
    CUDA_CHECK(cudaEventCreate(&start));
    CUDA_CHECK(cudaEventCreate(&stop));
    CUDA_CHECK(cudaEventRecord(start));

    convolutionKernel<<<blocks, threads>>>(d_in, d_out, WIDTH, HEIGHT);
    CUDA_CHECK(cudaEventRecord(stop));
    CUDA_CHECK(cudaEventSynchronize(stop));

    float ms = 0.0f;
    CUDA_CHECK(cudaEventElapsedTime(&ms, start, stop));
    std::cout << "Convolution kernel time: " << ms << " ms\n";

    // Copy result back to host
    CUDA_CHECK(cudaMemcpy(h_out, d_out, bytes, cudaMemcpyDeviceToHost));
    std::cout << "Sample output pixel [0]: " << h_out[0] << std::endl;

    // Clean up
    CUDA_CHECK(cudaFree(d_in));
    CUDA_CHECK(cudaFree(d_out));
    free(h_in);
    free(h_out);

    return 0;
}

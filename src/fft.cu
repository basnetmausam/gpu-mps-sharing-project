#include <stdio.h>
#include <cufft.h>
#include "common_utils.cuh"

#define N 16384

int main() {
    cufftHandle plan;
    cufftComplex *data;
    CUDA_CHECK(cudaMalloc((void**)&data, sizeof(cufftComplex) * N));

    CUFFT_CHECK(cufftPlan1d(&plan, N, CUFFT_C2C, 1));
    CUFFT_CHECK(cufftExecC2C(plan, data, data, CUFFT_FORWARD));

    printf("[fft] FFT computation completed successfully.\n");

    CUFFT_CHECK(cufftDestroy(plan));
    CUDA_CHECK(cudaFree(data));
    return 0;
}

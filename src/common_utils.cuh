// src/common_utils.cuh
#ifndef COMMON_UTILS_CUH
#define COMMON_UTILS_CUH

#include <cuda_runtime.h>
#include <cufft.h> // Needed for cufftResult
#include <iostream>

// CUDA error checking macro
#define CUDA_CHECK(call)                                                      \
    do {                                                                      \
        cudaError_t err = call;                                                \
        if (err != cudaSuccess) {                                              \
            std::cerr << "CUDA error at " << __FILE__ << ":" << __LINE__       \
                      << " code=" << static_cast<int>(err)                     \
                      << " \"" << cudaGetErrorString(err) << "\"" << std::endl;\
            exit(EXIT_FAILURE);                                                \
        }                                                                     \
    } while (0)

// cuFFT error checking macro
#define CUFFT_CHECK(call)                                                      \
    do {                                                                       \
        cufftResult err = call;                                                \
        if (err != CUFFT_SUCCESS) {                                            \
            std::cerr << "cuFFT error at " << __FILE__ << ":" << __LINE__       \
                      << " code=" << static_cast<int>(err)                     \
                      << std::endl;                                             \
            exit(EXIT_FAILURE);                                                \
        }                                                                      \
    } while (0)

// Kernel error checking after kernel launch
#define CUDA_KERNEL_CHECK() CUDA_CHECK(cudaGetLastError())

#endif // COMMON_UTILS_CUH

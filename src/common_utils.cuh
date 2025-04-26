// src/common_utils.cuh
#ifndef COMMON_UTILS_CUH
#define COMMON_UTILS_CUH

#include <cuda_runtime.h>
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

#endif // COMMON_UTILS_CUH

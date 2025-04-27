# Makefile

# Compiler
NVCC = nvcc

# Directories
SRC_DIR = src

# List of source files without extension
SRC_NAMES = matrix_mul memory_copy vector_add image_convolution prefix_sum fft

# Full paths for output binaries
BINARIES = $(addprefix $(SRC_DIR)/, $(SRC_NAMES))

# Compilation flags
NVCC_FLAGS = -O3 -std=c++14

# Special case for FFT linking
FFT_BINARY = $(SRC_DIR)/fft
FFT_LIB = -lcufft

# Default target
all: $(BINARIES)

# General build rule
$(SRC_DIR)/%: $(SRC_DIR)/%.cu $(SRC_DIR)/common_utils.cuh
	$(NVCC) $(NVCC_FLAGS) $< -o $@

# Special build rule for fft
$(FFT_BINARY): $(SRC_DIR)/fft.cu $(SRC_DIR)/common_utils.cuh
	$(NVCC) $(NVCC_FLAGS) $< -o $@ $(FFT_LIB)

# Clean target
clean:
	rm -f $(SRC_DIR)/*.out
	rm -f $(BINARIES)

.PHONY: all clean

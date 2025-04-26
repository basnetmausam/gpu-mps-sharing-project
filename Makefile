# Makefile at project root

CUDA = nvcc
SRC_DIR = src
BIN_DIR = src

PROGS = matrix_mul vector_reduction image_convolution

all: $(PROGS)

$(PROGS): %: 
	@echo "Building $@.cu -> $@.out"
	$(CUDA) $(SRC_DIR)/$@.cu -o $(BIN_DIR)/$@.out

clean:
	rm -f $(BIN_DIR)/*.out

#make simulate N=16 M=16

# Default values for N and M
WIDTH ?= 33

# Calculating N2 and M2 as N/2 + 1 and M/2 + 1
WIDTH2 := $(shell echo $$(($(WIDTH)/2 + 1)))

PIPE_STAGE_WIDTH ?= 2
PPM_TYPE ?= 0

generate_PPM: 
	../mult-tree/generate_PPM $(WIDTH2) $(WIDTH2)

simulate: generate_PPM
	iverilog -o simulate -DWIDTH=$(WIDTH) -DPIPE_STAGE_WIDTH=$(PIPE_STAGE_WIDTH) -DPPM_TYPE=$(PPM_TYPE) tb.v DSP_top.v DSP_model.v ../cells/*.v
	vvp simulate

simulate_modelsim: generate_PPM
	vlog +define+WIDTH=$(WIDTH) +define+PIPE_STAGE_WIDTH=$(PIPE_STAGE_WIDTH) +define+PPM_TYPE=$(PPM_TYPE) tb.v DSP_top.v DSP_model.v ../cells/*.v
	vsim tb -c -do "run -all"

.PHONY: simulate generate_PPM

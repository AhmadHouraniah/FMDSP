#make simulate N=16 M=16

# Default values for N and M
N ?= 33
M ?= 33

# Calculating N2 and M2 as N/2 + 1 and M/2 + 1
N2 := $(shell echo $$(($(N)/2 + 1)))
M2 := $(shell echo $$(($(M)/2 + 1)))

PIPES = 0
MULT = 0

generate_PPM: 
	./generate_PPM $(N2) $(M2)

simulate: generate_PPM
	iverilog -o simulate -DN=$(N) -DM=$(M) -DPIPES=$(PIPES) -DMULT=$(MULT) tb.v DSP_top.v DSP_model.v ../cells/*.v
	vvp simulate

.PHONY: simulate generate_PPM

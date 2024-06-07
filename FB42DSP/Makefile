#make simulate N=16 M=16

# Default values for N and M
N ?= 8
M ?= 8

# Calculating N2 and M2 as N/2 + 1 and M/2 + 1
N2 := $(shell echo $$(($(N)/2 + 1)))
M2 := $(shell echo $$(($(M)/2 + 1)))

PIPES = 0

generate_PPM: 
	./generate_PPM $(N2) $(M2)

simulate: generate_PPM
	iverilog -o simulate -DN=$(N) -DM=$(M) -DPIPES=$(PIPES) tb.v DSP_top.v DSP_model.v ../cells/*.v
	vvp simulate

.PHONY: simulate generate_PPM

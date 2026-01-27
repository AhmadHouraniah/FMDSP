#make simulate N=16 M=16

# Default values for N and M
WIDTH ?= 33

# Calculating N2 and M2 as N/2 + 1 and M/2 + 1
WIDTH2 := $(shell echo $$(($(WIDTH)/2 + 1)))

PIPE_STAGE_WIDTH ?= 2
PPM_TYPE ?= 0

generate_PPM: 
	$(MAKE) -C ../../mult-tree all OUT_DIR=$(shell pwd)
	./generate_PPM $(WIDTH2) $(WIDTH2) ../../design/cells

simulate: generate_PPM
	iverilog -o simulate -DWIDTH=$(WIDTH) -DPIPE_STAGE_WIDTH=$(PIPE_STAGE_WIDTH) -DPPM_TYPE=$(PPM_TYPE) tb.v ../../design/FB42DSP/DSP_top.v DSP_model.v ../../design/cells/*.v
	vvp simulate

simulate_modelsim: generate_PPM
	vlog +define+WIDTH=$(WIDTH) +define+PIPE_STAGE_WIDTH=$(PIPE_STAGE_WIDTH) +define+PPM_TYPE=$(PPM_TYPE) tb.v ../../design/FB42DSP/DSP_top.v DSP_model.v ../../design/cells/*.v
	vsim tb -c -do "run -all"

.PHONY: simulate generate_PPM

.PHONY: harden
harden: generate_PPM

	rm -rf ../../OpenLane/designs/FB42DSP/
	mkdir -p ../../OpenLane/designs/FB42DSP/
	cp ../../design/FB42DSP/*.v ../../OpenLane/designs/FB42DSP/
	cp ../../implementation/FB42DSP/* ../../OpenLane/designs/FB42DSP/
	cp ../../design/cells/*.v ../../OpenLane/designs/FB42DSP/

	docker run --rm \
		-v $(HOME):$(HOME) \
		-v $(shell pwd)/../../OpenLane:/openlane \
		-v $(shell pwd)/../../empty:/openlane/install \
		-v $(HOME)/.volare:$(HOME)/.volare \
		-e PDK_ROOT=$(HOME)/.volare \
		-e PDK=sky130A \
		--user $(shell id -u):$(shell id -g) \
		-e DISPLAY=$(DISPLAY) \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v $(HOME)/.Xauthority:/root/.Xauthority \
		--network host \
		--security-opt seccomp=unconfined \
		efabless/openlane:latest-amd64 \
		sh -c "./flow.tcl -design FB42DSP"

.PHONY: clean
clean:
	rm -f simulate dump.vcd generate_PPM
	rm -f ../../design/cells/wallace.v ../../design/cells/dadda.v


OPENLANE_TAG = $(shell cd ../../OpenLane && python3 dependencies/get_tag.py)
OPENLANE_IMAGE = ghcr.io/the-openroad-project/openlane:$(OPENLANE_TAG)-amd64

.PHONY: harden
harden:
	$(MAKE) -C ../../verification/FB32DSP generate_PPM
	rm -rf ../../OpenLane/designs/FB32DSP/
	mkdir -p ../../OpenLane/designs/FB32DSP/
	cp ../../design/FB32DSP/*.v ../../OpenLane/designs/FB32DSP/
	cp ./* ../../OpenLane/designs/FB32DSP/
	cp ../../design/cells/*.v ../../OpenLane/designs/FB32DSP/

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
		$(OPENLANE_IMAGE) \
		sh -c "./flow.tcl -design FB32DSP"

.PHONY: clean
clean:
	rm -rf ../../OpenLane/designs/FB32DSP/


OPENLANE_TAG = $(shell cd OpenLane && python3 dependencies/get_tag.py)
OPENLANE_IMAGE = ghcr.io/the-openroad-project/openlane:$(OPENLANE_TAG)-amd64

.PHONY: all
all: setup

.PHONY: setup
setup: submodules pdk docker-pull

.PHONY: submodules
submodules:
	git submodule update --init --recursive

.PHONY: pdk
pdk: submodules
	$(MAKE) -C OpenLane pdk PDK_ROOT=$(HOME)/.volare

.PHONY: docker-pull
docker-pull: submodules
	docker pull $(OPENLANE_IMAGE)

.PHONY: clean
clean:
	$(MAKE) -C verification/FB32DSP clean
	$(MAKE) -C verification/FB42DSP clean

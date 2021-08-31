MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
.PHONY:

TIME ?= time
DOCKER ?= docker
CURL ?= curl
TEST ?= test
SLEEP ?= sleep
GREP ?= grep
EXIT ?= exit

CONTAINER_REGISTRY ?=
CONTAINER_NAME ?= hausgold/mdns-proxy
CONTAINER_URI ?= $(CONTAINER_REGISTRY)$(CONTAINER_NAME)
CONTAINER_URI_DEV ?= $(CONTAINER_URI):dev
CONTAINER_URI_LATEST ?= $(CONTAINER_URI):latest

ON_ERROR := $(DOCKER) ps; $(DOCKER) logs mdns-test; $(EXIT) 1;

# Define a retry helper
define retry
	if eval "$(1)"; then exit 0; fi; \
	for i in 1; do sleep 10s; echo "Retrying $$i..."; \
		if eval "$(1)"; then exit 0; fi; \
	done; \
	exit 1
endef

# $(1) URL to test
# $(2) [Error handling]
define check-service
	@echo -n '> Wait for $(1) to answer (max 90s): '
	@$(SHELL) -c 'i=0; while ! $(CURL) -s $(1) >/dev/null; do \
		if [ $$i = 30 ]; then echo " Error: timeout."; $(2) exit 1; fi; \
		i=$$((i+1)); \
		echo -n "."; sleep 3; done'
	@$(SLEEP) 2
	@echo -e '\n> $(1) is running'
endef

# $(1) URL to test
# $(2) String which should be contained
# $(3) [Error handling]
define response-contains
	@$(CURL) -s $(1) | $(GREP) -Pzo $(2) || ($(CURL) -s $(1) || $(3) exit 1)
endef

all:
	# mDNS Proxy
	#
	# build          Build a development snapshot of the image
	# test           Test the built Docker image
	# publish        Push the new Docker image to the registry
	#
	# shell          You can start an individual session of the image for tests
	# clean          Clean the current development snapshot

build: clean
	# Build the Docker image
	@$(TIME) $(DOCKER) build --no-cache -t "$(CONTAINER_URI_DEV)" .

test:
	# Test the built Docker image
	#
	# Stop any tests of the Docker image
	@$(DOCKER) rm -fv mdns-test || true
	#
	# Start the built image
	@$(DOCKER) run --name mdns-test -p 80:80 -d "$(CONTAINER_URI_DEV)"
	#
	# Sleep a bit until the service is booted
	@$(call check-service,localhost:80,$(ON_ERROR))
	#
	# Search for 'HAUSGOLD'
	@$(call response-contains,localhost:80,\
		'good news: the mDNS.*\n.*proxy is up',$(ON_ERROR))

publish:
	# Push the new Docker image to the registry
	@$(DOCKER) tag "$(CONTAINER_URI_DEV)" "$(CONTAINER_URI_LATEST)"
	@$(call retry,$(TIME) $(SHELL) -c '$(DOCKER) push $(CONTAINER_URI_LATEST)')

shell:
	# Start an individual test session of the image
	@$(DOCKER) run --rm -it "$(CONTAINER_URI_DEV)" bash

clean:
	# Clean the current development snapshot
	@$(DOCKER) rmi --force "$(CONTAINER_URI_DEV)" || true

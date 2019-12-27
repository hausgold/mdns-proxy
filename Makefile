MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
.PHONY:

TIME ?= time
DOCKER ?= docker

CONTAINER_REGISTRY ?=
CONTAINER_NAME ?= hausgold/mdns-proxy
CONTAINER_URI ?= $(CONTAINER_REGISTRY)$(CONTAINER_NAME)
CONTAINER_URI_DEV ?= $(CONTAINER_URI):dev

all:
	# mDNS Proxy
	#
	# build          Build a development snapshot of the image
	#
	# shell          You can start an individual session of the image for tests
	# clean          Clean the current development snapshot

build: clean
	# Build the Docker image
	@$(TIME) $(DOCKER) build --no-cache -t "$(CONTAINER_URI_DEV)" .

shell:
	# Start an individual test session of the image
	@$(DOCKER) run --rm -it "$(CONTAINER_URI_DEV)" bash

clean:
	# Clean the current development snapshot
	@$(DOCKER) rmi --force "$(CONTAINER_URI_DEV)" || true

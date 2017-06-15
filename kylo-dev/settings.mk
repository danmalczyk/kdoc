MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
IMAGE_NAME := $(notdir $(patsubst %/,%,$(dir $(MKFILE_PATH))))
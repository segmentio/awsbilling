SHELL = /bin/bash

.PHONY: test install test-install prune clean minor
JSHINT := $(shell command -v jshint)
YARN := $(shell command -v yarn)

node_modules:
	yarn install

test-install:
	yarn add mocha

test: lint
	@echo "there are no tests. Roll forward."

lint: node_modules
	yarn run lint

prune:
	yarn install --production --ignore-scripts --prefer-offline

clean:
	rm -rf node_modules

minor:
	npm version minor

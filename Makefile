TESTS?=$(shell find test -name *_test.js)
REPORTER?=spec
MOCHA_OPTS=--reporter $(REPORTER) \
					 $(TESTS)

.PHONY: default
default: lint test

node_modules: package.json
	npm install
	# Workaround to ensure that this target is skipped when the previous run did
	# not retrieve any new modules.
	touch node_modules

b2g: node_modules
	./node_modules/.bin/mozilla-download --verbose --product b2g $@

.PHONY: lint
lint:
	gjslint  --recurse . \
		--disable "220,225" \
		--exclude_directories "b2g,examples,node_modules"

.PHONY: test-sync
test-sync: node_modules
	SYNC=true ./node_modules/.bin/marionette-mocha $(MOCHA_OPTS)

.PHONY: test-async
test-async: node_modules
	./node_modules/.bin/marionette-mocha $(MOCHA_OPTS)

.PHONY: test
test: b2g test-sync test-async

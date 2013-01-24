REPORTER = dot

build:
	@./node_modules/.bin/coffee -b -o lib src/*.coffee

doc: build
	@./node_modules/.bin/coffee src/doc.coffee

test: build
	@NODE_ENV=test ./node_modules/.bin/mocha --reporter $(REPORTER)

.PHONY: test

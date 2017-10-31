project = enum
sources = src/$(project)/*.lua
files = README.md $(sources)

.PHONY: check
check: test coverage lint

.PHONY: lint
lint: test
	luacheck .

.PHONY: test
test: tests/*.lua
	busted .

.PHONY: coverage
coverage: test
	busted --coverage .

docs: $(files)
	ldoc .

.PHONY: upload
upload: check
	luarocks upload rockspec/$(project)-$(LUA_ENUM_VERSION).rockspec

.PHONY: clean
clean:
	rm -rf luacov.*.out

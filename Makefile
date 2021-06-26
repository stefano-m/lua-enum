project = enum
sources = src/$(project)/*.lua
files = README.md $(sources)

.PHONY: flake
flake:
	nix flake check

.PHONY: check
check: lint test coverage

.PHONY: lint
lint:
	luacheck .

.PHONY: test
test: tests/*.lua
	busted .

.PHONY: coverage
coverage:
	busted --coverage .

docs: $(files)
	ldoc .

.PHONY: upload
upload: check
	luarocks upload rockspec/$(project)-$(LUA_ENUM_VERSION).rockspec

.PHONY: clean
clean:
	rm -rf luacov.*.out

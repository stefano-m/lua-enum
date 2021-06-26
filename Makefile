project = enum
sources = src/$(project)/*.lua
files = README.md $(sources)

tag ?=

.PHONY: release
ifndef tag
release:
	$(error Fatal: must specify tag)
else
release: flake
	@git status -s --untracked-files=no \
	| egrep '.+' >/dev/null \
	&& echo Cannot release with uncommitted files: \
	&& git status -s && exit 1 \
	|| true
	echo -n $(tag) > VERSION
	echo -e '* Release $(tag)\n' > RELEASE
	git shortlog -n `git tag | sort | tail -1`..HEAD >> RELEASE
	luarocks new_version --dir rockspec --tag $(tag)
	ldoc .
	git add RELEASE VERSION rockspec docs
	git commit -F RELEASE
	git tag -a $(tag) -F RELEASE
endif

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

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
	@echo -n $(tag) > VERSION
	echo -e '* Release $(tag)\n' > RELEASE
	@git shortlog -n `git tag | tr \. ' ' | sort  -k1.2n -k2n -k3n | tr ' ' \. | tail -1`..HEAD \
	| grep -v "Restart Development" >> RELEASE
	luarocks new_version --dir rockspec --tag $(tag)
	@sed -i 's/@VERSION@/$(tag)/' README.md src/enum/init.lua
	ldoc .
	@cat RELEASE CHANGELOG > CHANGELOG.2 && mv CHANGELOG.2 CHANGELOG
	git add src/enum/init.lua README.md CHANGELOG VERSION rockspec docs
	git commit -F RELEASE
	git tag -a $(tag) -F RELEASE
	@rm -f RELEASE
	@git reset HEAD~1 -- README.md src/enum/init.lua
	@git commit -m "Restart Development"
	@git co -- README.md src/enum/init.lua
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
	rm -rf luacov.*.out result

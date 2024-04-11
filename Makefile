# TODO v18 is not yet available https://github.com/Homebrew/homebrew-core/pull/165206
BREW_LLM_VERSION := llvm@17

setup:
		if ! brew list $(BREW_LLM_VERSION) >/dev/null 2>&1; then \
				brew install $(BREW_LLM_VERSION); \
		fi

# right now, only globally installed packages work with the vscode extension
# make sure the global path is unset!
		bundle config unset --global path

# ruby-ffi doesn't look at the right location for llvm by default
		PATH=$(PATH):$(shell brew --prefix $(BREW_LLM_VERSION))/bin DYLD_LIBRARY_PATH=$(shell brew --prefix $(BREW_LLM_VERSION))/lib:$(DYLD_LIBRARY_PATH) bundle install


VSCODE_INSTALLATION_PATH := ~/.vscode/extensions/ryanstout.vscode-stout-lang

# TODO obviously, this is terrible
STOUTLANG_LIB := $(PWD)/stoutlang

vscode-install:
	rm -rf $(VSCODE_INSTALLATION_PATH)
	cp -R lsp/vscode/sl $(VSCODE_INSTALLATION_PATH)
	sed -i '' 's|STOUTLANG_PATH = .*|STOUTLANG_PATH = "$(STOUTLANG_LIB)"|' ~/.vscode/extensions/ryanstout.vscode-stout-lang/src/ruby_lsp_server.rb
	@echo "You must manually 'Restart Extension Host'"

clean:
	rm -rf vendor/bundle
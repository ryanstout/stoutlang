# TODO v18 is not yet available https://github.com/Homebrew/homebrew-core/pull/165206
BREW_LLM_VERSION := llvm@17

setup:
		if ! brew list $(BREW_LLM_VERSION) >/dev/null 2>&1; then \
				brew install $(BREW_LLM_VERSION); \
		fi

# ruby-ffi doesn't look at the right location for llvm by default
		PATH=$$PATH:$(shell brew --prefix $(BREW_LLM_VERSION))/bin DYLD_LIBRARY_PATH=$(shell brew --prefix $(BREW_LLM_VERSION))/lib:$$(DYLD_LIBRARY_PATH) bundle install

clean:
	rm -rf vendor/bundle
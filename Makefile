
PIPPATH = $(HOME)/.local/bin

help:
	@echo
	@echo 'Available commands:'
	@echo '  make deps - Install the prerequisite code analysis tools.'
	@echo '  make fmt - Apply automatic code formatting. (shell)'
	@echo '  make lint - Check for frequent issues in code. (shell)'
	@echo
.PHONY: help

deps:
	pip install black isort pylint flake8
	@echo
	@echo 'Done. Please also install manually with apt or dnf: shellcheck shfmt gitleaks'
	@echo
.PHONY: deps

fmt: shfmt # TODO: black isort
.PHONY: fmt

lint: shellcheck # TODO: gitleaks flake8 pylint
.PHONY: lint

shfmt:
	shfmt -ln=bash -l build/build.sh test/vm.sh | xargs shfmt -w -l -ln=bash -i 4 -ci -bn
.PHONY: shfmt

shellcheck:
	shellcheck -S warning build/build.sh test/vm.sh
.PHONY: shellcheck

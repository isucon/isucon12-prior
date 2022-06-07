### Build variables

GO?=go

GO_FILES=$(shell find . -name '*.go' -print)

.PHONY: all
all: ## Run all targets
all: build

.PHONY: build
build: ## Build artifacts
build: bin/web

.PHONY: test
test: ## Run tests
test: ${TMPDIR}/cover.html

.PHONY: clean
clean: ## Cleanup artifacts
clean:
	@${RM} -r ./bin
	@${RM} -r ./tmp

.PHONY: help
help: ## Show help
help:
	@grep -E '^[a-zA-Z_/-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

### Real targets

go.sum: go.mod
	@${GO} mod tidy

bin/web: go.mod go.sum ${GO_FILES} ${MAKEFILE_LIST}
	@${GO} build -o $@ -- .

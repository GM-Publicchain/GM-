# golang1.9 or latest

=github.com/ganma/GM
_PATH=vendor/${GM}
plugin=github.com/GM/plugin
PKG_LIST_VET := `go list ./... | grep -v "vendor" | grep -v plugin/dapp/evm/executor/vm/common/crypto/bn256`
PKG_LIST_INEFFASSIGN= `go list -f {{.Dir}} ./... | grep -v "vendor"`
.PHONY: default build

default: build

all: vendor build

build:
	go build -v -i -o ganma
	go build -v -i -o ganma-cli github.com/ganma/GM/cli


vendor:
	make update
	#make updatevendor

update:
	go get -u -v github.com/kardianos/govendor
	rm -rf vendor/${GM}
	rm -rf vendor/${plugin}
	rm -rf vendor/github.com/apache/thrift/tutorial/erl/
	git clone --depth 1 -b master https://${plugin}.git vendor/${plugin}
#	git clone --depth 1 -b update_c_191116 https://github.com/vipwzw/plugin.git vendor/${plugin}
	rm -rf vendor/${plugin}/.git
	cp -Rf vendor/${plugin}/vendor/* vendor/
	rm -rf vendor/${plugin}/vendor

	govendor init
	go build -i -o tool github.com/ganma/GM/vendor/github.com/GM/ganma/cmd/tools
	./tool import --path "plugin" --packname "github.com/ganma/GM/plugin" --conf "plugin/plugin.toml"

updatevendor:
	govendor add +e
	govendor fetch -v +m

vet:
	@go vet ${PKG_LIST_VET}

ineffassign:
	@ineffassign -n ${PKG_LIST_INEFFASSIGN}

linter: vet ineffassign ## Use gometalinter check code, ignore some unserious warning
	@./golinter.sh "filter"
	#@find . -name '*.sh' -not -path "./vendor/*" | xargs shellcheck

.PHONY: checkgofmt
checkgofmt: ## get all go files and run go fmt on them
	@files=$$(find . -name '*.go' -not -path "./vendor/*" | xargs gofmt -l -s); if [ -n "$$files" ]; then \
		  echo "Error: 'make fmt' needs to be run on:"; \
		  echo "${files}"; \
		  exit 1; \
		  fi;
	@files=$$(find . -name '*.go' -not -path "./vendor/*" | xargs goimports -l -w); if [ -n "$$files" ]; then \
		  echo "Error: 'make fmt' needs to be run on:"; \
		  echo "${files}"; \
		  exit 1; \
		  fi;

fmt_shell: ## check shell file
	@find . -name '*.sh' -not -path "./vendor/*" | xargs shfmt -w -s -i 4 -ci -bn

fmt: fmt_shell ## go fmt
	@go fmt ./...
	@find . -name '*.go' -not -path "./vendor/*" | xargs goimports -l -w

autotest: ## build autotest binary
	@cd build/autotest && bash ./build.sh && cd ../../
	@if [ -n "$(dapp)" ]; then \
		rm -rf build/autotest/local \
		&& cp -r $(CHAIN33_PATH)/build/autotest/local $(C_PATH)/build/autotest/*.sh build/autotest/ \
		&& cd build/autotest && bash ./copy-autotest.sh local && cd local && bash ./local-autotest.sh $(dapp) && cd ../../../; fi


clean:
	@rm -rf vendor
	@rm -rf datadir
	@rm -rf logs
	@rm -rf wallet
	@rm -rf grpc.log
	@rm -rf ganma
	@rm -rf ganma-cli
	@rm -rf tool
	@rm -rf plugin/init.go
	@rm -rf plugin/consensus/init
	@rm -rf plugin/dapp/init
	@rm -rf plugin/crypto/init
	@rm -rf plugin/store/init

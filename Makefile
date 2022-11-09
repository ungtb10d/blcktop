# builds .rpm and .deb packages
# requires dockerd to be running
# builds the packages for amd64

VERSION=$(shell go run main.go -V)
ARCHIVE="gotop_$(VERSION)_linux_amd64"

.PHONY: all
all: dist/blcktop.rpm dist/blcktop.deb

dist/blcktop:
	@GOOS=linux GOARCH=amd64 go build -o $@

dist:
	@mkdir $@

dist/blcktop.rpm: dist dist/blcktop
	@docker run --rm \
	-v "$(PWD)/build:/tmp/build" \
	-v "$(PWD)/dist:/tmp/dist" \
	-e "VERSION=$(VERSION)" \
	goreleaser/nfpm pkg \
		--config /tmp/build/nfpm.yml \
		--target /tmp/dist/$(ARCHIVE).rpm

dist/blcktop.deb: dist dist/blcktop
	@docker run --rm \
	-v "$(PWD)/build:/tmp/build" \
	-v "$(PWD)/dist:/tmp/dist" \
	-e "VERSION=$(VERSION)" \
	goreleaser/nfpm pkg \
		--config /tmp/build/nfpm.yml \
		--target /tmp/dist/$(ARCHIVE).deb

.PHONY: clean
clean:
	@-rm -rf dist

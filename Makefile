PAK_NAME := $(shell jq -r .label config.json)

ARCHITECTURES := arm arm64

DROPBEAR_VERSION ?= 2024.86

clean:
	rm -f bin/*/dropbear || true

build: $(foreach arch,$(ARCHITECTURES),bin/$(arch)/dropbear)

# also creates dbclient, dropbearkey, dropbearconvert, and scp
bin/%/dropbear:
	mkdir -p bin/$*
	docker buildx build --platform linux/$* --load -f $*/dropbear/Dockerfile --progress plain -t app/dropbear:$(DROPBEAR_VERSION)-$* $*/dropbear/
	docker container create --name extract app/dropbear:$(DROPBEAR_VERSION)-$*
	docker container cp extract:/go/src/github.com/mkj/dropbear/dropbear bin/$*/dropbear
	docker container rm extract
	chmod +x bin/$*/dropbear

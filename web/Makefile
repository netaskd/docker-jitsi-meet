build:
	./patch/builder
	docker build $(BUILD_ARGS) -t $(JITSI_REPO)/web -f Dockerfile.patch .

.PHONY: build

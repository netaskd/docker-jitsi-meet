build:
	./rootfs/builder
	docker build $(BUILD_ARGS) -t $(JITSI_REPO)/web -f Dockerfile.spo .

.PHONY: build

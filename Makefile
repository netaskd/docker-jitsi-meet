# make sure that .make-env exisis
include .make-env
#include .make-env-dev
export

BUILD_ARGS := --build-arg JITSI_REPO=$(JITSI_REPO)
ifeq ($(FORCE_REBUILD), 1)
  BUILD_ARGS := $(BUILD_ARGS) --no-cache
endif


all:	build-all

release: tag-all push-all

build:  versioning
	$(MAKE) BUILD_ARGS="$(BUILD_ARGS) --build-arg VERSION=$(VERSION)" -C $(SERVICE) build

tag:	versioning
	docker tag $(JITSI_REPO)/$(SERVICE):latest $(JITSI_REPO)/$(SERVICE):$(or $(VERSION),$(JITSI_BUILD))

back:
	docker tag $(JITSI_REPO)/$(JITSI_SERVICE):$(JITSI_BUILD) $(JITSI_REPO)/$(JITSI_SERVICE):bak

unback:
	docker tag $(JITSI_REPO)/$(JITSI_SERVICE):bak $(JITSI_REPO)/$(JITSI_SERVICE):$(JITSI_BUILD)

push:	versioning
	docker push $(JITSI_REPO)/$(SERVICE):$(or $(VERSION),$(JITSI_BUILD))

%-all:
	@$(foreach SERVICE, $(JITSI_SERVICES), $(MAKE) --no-print-directory JITSI_SERVICE=$(SERVICE) $(subst -all,;,$@))

versioning:
	$(eval SERVICE_VERSION := $(subst =, ,$(JITSI_SERVICE)))
	$(eval SERVICE := $(word 1, $(SERVICE_VERSION)))
	$(eval VERSION := $(word 2, $(SERVICE_VERSION)))

clean:
	docker-compose stop
	docker-compose rm
	docker network prune

.PHONY: all build tag push clean

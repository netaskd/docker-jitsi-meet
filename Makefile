FORCE_REBUILD ?= 0
JITSI_RELEASE ?= stable
JITSI_BUILD ?= latest
JITSI_REPO ?= jitsi
#JITSI_SERVICES ?= base base-java web prosody jicofo jvb jigasi jibri etherpad turn
JITSI_SERVICES ?= base base-java web=1.0.3992-1 prosody=0.11.5-1 jicofo=1.0-544-1 jvb=2.1-169-ga28eb88e-1 jigasi=1.1-40-gbcb33f2-1 jibri=8.0-14-g0ccc3f6-1 etherpad=1.8.0 etherdraw=1.0 turn=4.5.1.1

BUILD_ARGS := --build-arg JITSI_REPO=$(JITSI_REPO)
ifeq ($(FORCE_REBUILD), 1)
  BUILD_ARGS := $(BUILD_ARGS) --no-cache
endif


all:	build-all

release: tag-all push-all

build:  versioning
	$(MAKE) BUILD_ARGS="$(BUILD_ARGS) --build-arg VERSION=$(VERSION)" JITSI_RELEASE="$(JITSI_RELEASE)" -C $(SERVICE) build

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

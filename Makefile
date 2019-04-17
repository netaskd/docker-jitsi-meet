FORCE_REBUILD ?= 0
JITSI_RELEASE ?= "stable"
JITSI_BUILD ?= "latest"
JITSI_REPO ?= "jitsi"

ifeq ($(FORCE_REBUILD), 1)
  BUILD_ARGS = "--no-cache"
endif

build-all:
	BUILD_ARGS=$(BUILD_ARGS) JITSI_RELEASE=$(JITSI_RELEASE) $(MAKE) -C base build
	BUILD_ARGS=$(BUILD_ARGS) $(MAKE) -C base-java build
	BUILD_ARGS=$(BUILD_ARGS) $(MAKE) -C web build
	BUILD_ARGS=$(BUILD_ARGS) $(MAKE) -C prosody build
	BUILD_ARGS=$(BUILD_ARGS) $(MAKE) -C jicofo build
	BUILD_ARGS=$(BUILD_ARGS) $(MAKE) -C jvb build
	BUILD_ARGS=$(BUILD_ARGS) $(MAKE) -C jigasi build
	BUILD_ARGS=$(BUILD_ARGS) $(MAKE) -C jibri build
	BUILD_ARGS=$(BUILD_ARGS) $(MAKE) -C etherpad build

tag-all:
	docker tag jitsi/base:latest $(JITSI_REPO)/base:$(JITSI_BUILD)
	docker tag jitsi/base-java:latest $(JITSI_REPO)/base-java:$(JITSI_BUILD)
	docker tag jitsi/web:latest $(JITSI_REPO)/web:$(JITSI_BUILD)
	docker tag jitsi/prosody:latest $(JITSI_REPO)/prosody:$(JITSI_BUILD)
	docker tag jitsi/jicofo:latest $(JITSI_REPO)/jicofo:$(JITSI_BUILD)
	docker tag jitsi/jvb:latest $(JITSI_REPO)/jvb:$(JITSI_BUILD)
	docker tag jitsi/jigasi:latest $(JITSI_REPO)/jigasi:$(JITSI_BUILD)
	docker tag jitsi/jibri:latest $(JITSI_REPO)/jibri:$(JITSI_BUILD)
	docker tag jitsi/etherpad:latest $(JITSI_REPO)/etherpad:$(JITSI_BUILD)

push-all:
	docker push $(JITSI_REPO)/base:$(JITSI_BUILD)
	docker push $(JITSI_REPO)/base-java:$(JITSI_BUILD)
	docker push $(JITSI_REPO)/web:$(JITSI_BUILD)
	docker push $(JITSI_REPO)/prosody:$(JITSI_BUILD)
	docker push $(JITSI_REPO)/jicofo:$(JITSI_BUILD)
	docker push $(JITSI_REPO)/jvb:$(JITSI_BUILD)
	docker push $(JITSI_REPO)/jigasi:$(JITSI_BUILD)
	docker push $(JITSI_REPO)/jibri:$(JITSI_BUILD)
	docker push $(JITSI_REPO)/etherpad:$(JITSI_BUILD)

clean:
	docker-compose stop
	docker-compose rm
	docker network prune

.PHONY: build-all tag-all push-all clean

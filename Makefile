BRANCH_NAME ?= $(shell git rev-parse --abbrev-ref HEAD)
GIT_BRANCH := $(BRANCH_NAME)
GIT_REVISION := $(shell git rev-parse --short HEAD)
GIT_COMMIT_COUNT := $(shell git rev-list --count HEAD)
SAFE_BRANCH_NAME := $(shell echo '$(GIT_BRANCH)' | tr '[:upper:]' '[:lower:]' | tr -s -c '\n\-\+a-z0-9' '-')

# If we are not building on master, set URL and namespace from branch name
ifneq '$(GIT_BRANCH)' 'master'
IMAGE_TAG := $(SAFE_BRANCH_NAME)-$(GIT_REVISION)
URL_HOSTNAME = $(SAFE_BRANCH_NAME).dev.maersk-digital.net
K8S_NAMESPACE = $(SAFE_BRANCH_NAME)
else
# On master set a static URL and namespace
IMAGE_TAG := $(GIT_COMMIT_COUNT)-$(GIT_REVISION)
URL_HOSTNAME = k8s-feature-deploys.dev.maersk-digital.net
K8S_NAMESPACE = k8s-feature-deploys
endif

CONTAINER_REGISTRY ?= revenueoptimisation.azurecr.io/
IMAGE_NAME = k8s-feature-deploys
REGISTRY_IMAGE_NAME = $(CONTAINER_REGISTRY)$(IMAGE_NAME)

help:
	@echo "help                     This help message"
	@echo "build                    Build the docker image"
	@echo "k8s_deploy               Deploy to Kubernetes"

build:
	docker build . -t $(IMAGE_NAME):$(IMAGE_TAG)

ci-tag-registry: build
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) \
	$(REGISTRY_IMAGE_NAME):$(IMAGE_TAG)

ci-push: ci-tag-registry registry-login
	docker push $(REGISTRY_IMAGE_NAME):$(IMAGE_TAG)

ci-export-url: _url_hostname.txt

_url_hostname.txt: FORCE
	echo '$(URL_HOSTNAME)' > $@

registry-login:
	@test -n "$(REGISTRY_CRED_USR)" || (echo "Environment variable REGISTRY_CRED_USR not set"; exit 1)
	@test -n "$(REGISTRY_CRED_PSW)" || (echo "Environment variable REGISTRY_CRED_PSW not set"; exit 1)
	@echo 'docker login -u $$(REGISTRY_CRED_USR) -p $$(REGISTRY_CRED_PSW) $$(CONTAINER_REGISTRY)'
	@docker login -u $(REGISTRY_CRED_USR) -p $(REGISTRY_CRED_PSW) $(CONTAINER_REGISTRY)

# REGISTRY_CRED_ are exported by Jenkins
k8s_deploy: REGISTRY_CRED_USR ?=
k8s_deploy: REGISTRY_CRED_PSW ?=
k8s_deploy:
	IMAGE_TAG=$(IMAGE_TAG) \
	URL_HOSTNAME=$(URL_HOSTNAME) \
	K8S_NAMESPACE=$(K8S_NAMESPACE) \
	REGISTRY_CRED_USR=$(REGISTRY_CRED_USR) \
	REGISTRY_CRED_PSW=$(REGISTRY_CRED_PSW) \
	CONTAINER_REGISTRY=$(CONTAINER_REGISTRY) \
	SAFE_BRANCH_NAME=$(SAFE_BRANCH_NAME) \
	$(MAKE) -C k8s/ k8s_deploy

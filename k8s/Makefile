REGISTRY_CRED_USR ?=
REGISTRY_CRED_PSW ?=

# What is the tag for the images to be deployed
IMAGE_TAG ?=
URL_HOSTNAME ?=
K8S_NAMESPACE ?=
CONTAINER_REGISTRY ?=
REGISTRY_IMAGE_NAME ?=
SAFE_BRANCH_NAME ?=

$(if $(REGISTRY_CRED_USR),,$(error REGISTRY_CRED_USR variable not set))
$(if $(REGISTRY_CRED_PSW),,$(error REGISTRY_CRED_PSW variable not set))
$(if $(IMAGE_TAG),,$(error IMAGE_TAG variable not set))
$(if $(URL_HOSTNAME),,$(error URL_HOSTNAME variable not set))
$(if $(K8S_NAMESPACE),,$(error K8S_NAMESPACE variable not set))
$(if $(CONTAINER_REGISTRY),,$(error CONTAINER_REGISTRY variable not set))
$(if $(REGISTRY_IMAGE_NAME),,$(error REGISTRY_IMAGE_NAME variable not set))
$(if $(SAFE_BRANCH_NAME),,$(error SAFE_BRANCH_NAME variable not set))

k8s_deploy: k8s_create-namespace k8s_apply_configuration k8s_generate_configuration_files
	test -n '$(K8S_NAMESPACE)'
	kubectl apply -R -f _k8s_deploy/

k8s_create-namespace:
	test -n '$(K8S_NAMESPACE)'
	kubectl get namespace $(K8S_NAMESPACE) || \
		kubectl create namespace $(K8S_NAMESPACE)

k8s_apply_configuration: \
	k8s_add-registry-secret

k8s_add-registry-secret: SECRET_NAME = k8s-feature-deploys-secrets
k8s_add-registry-secret:
	@test -n '$(REGISTRY_CRED_USR)'
	@test -n '$(REGISTRY_CRED_PSW)'
	kubectl --namespace='$(K8S_NAMESPACE)' get secret $(SECRET_NAME) || \
		kubectl --namespace='$(K8S_NAMESPACE)' create secret docker-registry $(SECRET_NAME) \
			--docker-username=$(REGISTRY_CRED_USR) \
			--docker-password=$(REGISTRY_CRED_PSW) \
			--docker-server=$(CONTAINER_REGISTRY) \
			--docker-email=niels.busch@gmail.com

k8s_generate_configuration_files: \
	_k8s_deploy/deployment.yaml \
	_k8s_deploy/ingress.yaml \
	_k8s_deploy/service.yaml

_k8s_deploy/:
	mkdir -p $@

_k8s_deploy/%.yaml: %.template.yaml _k8s_deploy/ FORCE
	sed \
	-e 's/__K8S_NAMESPACE__/$(K8S_NAMESPACE)/g' \
	-e 's/__IMAGE_TAG__/$(IMAGE_TAG)/g' \
	-e 's/__URL_HOSTNAME__/$(URL_HOSTNAME)/g' \
	-e 's;__REGISTRY_IMAGE_NAME__;$(REGISTRY_IMAGE_NAME);g' \
	$< > $@

FORCE:

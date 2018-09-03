# k8s-feature-deploys

This repository shows how to enable feature deploys using k8s.

## Problem

Often times you have a fixed set of deployment environments. Production,
Pre-Prod, Test, etc. This limits how you can share features and bug
fixes with others. In some cases you will have multiple unrelated changes
deployed to the same environment, making it much harder to reason about. You
also need to be more careful with migrations and be sure to roll back to a known
state. All this leads to a case where rapid iteration and feedback is not
utilised as much as it could be.

## Solution

Feature deploys solves this by giving you a flexible environment with unlimited
isolated deployments. You can easily test out a new feature or bug fix and be
sure it's not impacted by other feature branches.

## How it works

Feature deploys allows you to automatically deploy a git branch to a separate
deployment with it's own URL and K8S namespace. If the branch name is
prepended with `feature-` it will be picked up by Jenkins and deployed. The
feature URL will be posted in a slack channel once the deploy has been applied.

Feature deploys works by deploying to a new Kubernetes namespace for each
feature branch. In addition it sets a new URL based on the branch name.

## Usage

### Manually deploying to Kubernetes

#### Prerequisites

In order to deploy to Kubernetes you must have a cluster and the kubectl
command working accordingly.

You must set the env vars `CONTAINER_REGISTRY`, `REGISTRY_CRED_USR` and `REGISTRY_CRED_PSW` for your container registry.

#### Deploying

Run the following command to deploy the example app `make ci-push k8s_deploy`.

If you are running the cluster locally you might need to forward the deployment to a local port.

```console
kubectl get pods --namespace=k8s-feature-deploy
NAME                                              READY     STATUS    RESTARTS   AGE
k8s-feature-deploys-deployment-6875595c55-mzkx9   1/1       Running   0          2d
```

```console
kubectl port-forward k8s-feature-deploys-deployment-6875595c55-mzkx9 8000:80 --namespace=k8s-feature-deploys
```

If all went well you can point your browser at http://localhost:8000.

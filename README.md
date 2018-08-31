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

## Credits

This repo has been extracted from UDF_APP feature deploys made by Lasse Bach.

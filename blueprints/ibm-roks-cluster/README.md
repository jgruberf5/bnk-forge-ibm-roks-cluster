# IBM ROKS Cluster Blueprint

## Solution Description

Provisions IBM Cloud ROKs cluster and attached Transit Gateway.

This blueprint is intended to import into Forge as an Infrastructure blueprint with IBM as the cloud provider.

## What You Get

- IBM ROKS cluster creation
- IBM COS instance for the cluster registry using a name derived from the cluster name
- IBM transit gateway using a name derived from the cluster name
- Outputs that let BNK register the cluster into the Operate Kubernetes inventory

## Prerequisites

- The `modules/cluster` deployment pack from this repository must already be synced into Forge
- An IBM Cloud credential template or project secret must provide `ibmcloud_api_key`
- The target IBM account and region must support the requested ROKS worker sizing

## Modules

### ROKS Cluster

Uses `modules/cluster` to provision the IBM ROKS cluster, registry COS instance, and transit gateway in one deployment step.

## Input Variables

Provide the IBM Cloud API key, region, resource group, cluster name, worker count per zone, and optional worker sizing overrides. The module derives `cos_instance_name` and `transit_gateway_name` directly from `roks_cluster_name`. In Forge, the IBM Cloud credential template can prefill the API key and region, and now also carries a default IBM resource group for stack deployments.

# skmo Ansible Role

This role prepares a multi-region SKMO environment across one or more RHOSO deployments (OpenStack on OpenShift).

It automates:
- Skupper setup to interconnect namespaces/clusters and expose regionZero Keystone private endpoint
- Creation of service users in workload regions and mirroring them in regionZero Keystone
- Creation of Keystone regions (in regionZero) for each workload region
- Registration of service endpoints (in regionZero) pointing to workload regions (excluding Keystone)
- Generation of Horizon configuration snippets (in regionZero) to surface multi-region selection
- Generation of control-plane config snippets for workload regions to use regionZero Keystone and correct region

## Inputs
Set via role vars or play vars:

- `skmo_namespaces`: list of objects describing each deployment
  - `name`: Kubernetes namespace
  - `cluster_context`: optional kubecontext name (if different cluster)
  - `region`: keystone region name to assign for this workload (not used for regionZero)
  - `is_region_zero`: bool; exactly one must be true
- `skmo_skupper_address_prefix`: string; base name for skupper addresses
- `skmo_openstack_clouds`: map of clouds for openstack.cloud collection
  - `region_zero_cloud`: cloud name in clouds.yaml for regionZero
  - `workload_clouds`: list of clouds (one per workload) or map by namespace

## Usage
Example playbook snippet:

```yaml
- hosts: localhost
  gather_facts: false
  roles:
    - role: skmo
      vars:
        skmo_namespaces:
          - name: regionzero-ns
            cluster_context: ocp-hub
            is_region_zero: true
          - name: workload1-ns
            cluster_context: ocp-edge1
            region: regionOne
            is_region_zero: false
        skmo_skupper_address_prefix: "skmo-ks"
        skmo_openstack_clouds:
          region_zero_cloud: regionzero
          workload_clouds:
            - workload1
```

## Requirements
- `oc` and `skupper` CLIs available to Ansible control host
- Access to all target clusters/namespaces (kubeconfig contexts)
- OpenStack clouds.yaml contexts resolvable by the `openstack.cloud` Ansible collection

## Notes
This initial version scaffolds tasks and provides idempotent structures; provider-specific details (e.g., service discovery of addresses) may need tuning for your environment. 
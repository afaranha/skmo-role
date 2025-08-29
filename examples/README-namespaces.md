# OpenStack Multi-Namespace Deployment

This guide explains how to deploy OpenStack services to different namespaces on different servers.

## Overview

The OpenStack role now supports deploying services to custom namespaces, allowing multiple independent OpenStack deployments on the same cluster or different clusters.

## Configuration

### Inventory Variables

Configure namespaces per server in your inventory:

```yaml
crc_servers:
  hosts:
    afariasa-region-1:
      ansible_host: 10.0.79.173
      openstack_namespace: "openstack-region-1"
      openstack_operators_namespace: "openstack-operators"
      
    afariasa-region-2:
      ansible_host: 10.0.79.110  
      openstack_namespace: "openstack-region-2"
      openstack_operators_namespace: "openstack-operators"
```

### Key Variables

- `openstack_namespace`: Target namespace for OpenStack services (unique per server)
- `openstack_operators_namespace`: Namespace for operators (typically shared)

## Deployment Steps

### 1. Deploy OpenStack Services with Custom Namespaces

```bash
cd examples
ansible-playbook -i inventory.yml deploy-openstack-services.yml
```

This will:
- Create the target namespace if it doesn't exist
- Initialize OpenStack in the specified namespace
- Deploy OpenStack control plane services

### 2. Verify Deployment

Check services in each namespace:

```bash
# Region 1
oc get pods -n openstack-region-1

# Region 2  
oc get pods -n openstack-region-2

# Shared operators
oc get pods -n openstack-operators
```

### 3. Manual Deployment Commands

For manual deployment with custom namespace:

```bash
ssh fedora@<server-ip>
cd /home/fedora/openstack/install_yamls
export PATH="/home/fedora/bin:$PATH"
eval $(crc oc-env)
export NAMESPACE="openstack-region-X"  # Set your target namespace
make openstack_init
make openstack_deploy
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    OpenShift Cluster                        │
├─────────────────────────────────────────────────────────────┤
│  openstack-operators (Shared)                              │
│  ├── infra-operator                                         │
│  ├── openstack-operator                                     │
│  └── openstack-baremetal-operator                          │
├─────────────────────────────────────────────────────────────┤
│  openstack-region-1                                        │
│  ├── keystone, mariadb, rabbitmq, etc.                     │
│  └── OpenStack services for region 1                       │
├─────────────────────────────────────────────────────────────┤
│  openstack-region-2                                        │
│  ├── keystone, mariadb, rabbitmq, etc.                     │
│  └── OpenStack services for region 2                       │
└─────────────────────────────────────────────────────────────┘
```

## Benefits

- **Isolation**: Each region has independent OpenStack services
- **Resource Management**: Separate resource quotas and limits per namespace
- **Multi-tenancy**: Support multiple OpenStack deployments
- **Shared Operators**: Efficient operator resource usage

## Examples

See the following playbooks:
- `deploy-openstack-services.yml` - Deploy to custom namespaces
- `inventory.yml` - Example namespace configuration
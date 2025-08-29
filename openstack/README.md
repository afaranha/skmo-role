# OpenStack Role

This Ansible role deploys OpenStack operators using the official install_yamls methodology.

## Description

This role handles the OpenStack operators installation and initialization from the install_yamls workflow. It assumes that CRC is already running and properly configured, and focuses specifically on:

1. `make openstack` - Install OpenStack operators
2. `make openstack_init` - Initialize OpenStack
3. `make openstack_deploy` - Deploy OpenStack control plane (optional)

## Requirements

- **Target OS**: Fedora 38+, RHEL/CentOS 8+
- **Prerequisites**: 
  - CRC must be running (use the `crc` role first)
  - install_yamls repository cloned to `/home/fedora/openstack/install_yamls`
  - CRC storage and input secrets configured
- **SSH**: Key-based authentication to target servers

## Role Variables

### Default Variables (openstack/defaults/main.yml)

```yaml
# User configuration
openstack_user: fedora

# Path configuration
openstack_install_yamls_path: "/home/{{ openstack_user }}/openstack/install_yamls"
openstack_bin_path: "/home/{{ openstack_user }}/bin"

# Timeout settings (seconds)
openstack_operators_timeout: 1800  # 30 minutes
openstack_init_timeout: 600        # 10 minutes

# Steps to execute
openstack_run_operators: true
openstack_run_init: true           # Run openstack_init after operators
openstack_run_deploy: false       # Optional deployment step

# OpenStack deployment options
openstack_deploy_control_plane: false  # Set to true to automatically deploy control plane
```

## Dependencies

- CRC must be running and accessible
- Storage and input configuration should be completed first

## Example Playbook

### Basic Usage (Operators Only)

```yaml
---
- name: Install OpenStack operators
  hosts: crc_servers
  become: false
  gather_facts: true
  roles:
    - openstack
```

### Full Deployment (Operators + Control Plane)

```yaml
---
- name: Deploy OpenStack operators and control plane
  hosts: crc_servers
  become: false
  gather_facts: true
  roles:
    - role: openstack
      vars:
        openstack_deploy_control_plane: true
        openstack_run_deploy: true
```

### Combined with CRC Role

```yaml
---
- name: Complete CRC and OpenStack deployment
  hosts: crc_servers
  become: false
  gather_facts: true
  roles:
    - role: crc
      vars:
        crc_run_openstack: false  # Skip OpenStack in CRC role
    - role: openstack
      vars:
        openstack_deploy_control_plane: true
        openstack_run_deploy: true
```

### Custom Timeout

```yaml
---
- name: Install OpenStack with extended timeout
  hosts: crc_servers
  become: false
  gather_facts: true
  roles:
    - role: openstack
      vars:
        openstack_operators_timeout: 3600  # 60 minutes
        openstack_init_timeout: 1200       # 20 minutes
```

### Skip Initialization Step

```yaml
---
- name: Install operators without initialization
  hosts: crc_servers
  become: false
  gather_facts: true
  roles:
    - role: openstack
      vars:
        openstack_run_init: false  # Skip openstack_init step
```

## Tags

The role supports the following tags for selective execution:

- `verify_prerequisites` - Verify CRC is running
- `openstack_operators` - Install OpenStack operators
- `openstack_init` - Initialize OpenStack
- `openstack_deploy` - Deploy OpenStack control plane
- `summary` - Final status display

### Example Tag Usage

```bash
# Install operators only
ansible-playbook playbook.yml --tags "openstack_operators"

# Initialize OpenStack only
ansible-playbook playbook.yml --tags "openstack_init"

# Deploy control plane only (assumes operators and init completed)
ansible-playbook playbook.yml --tags "openstack_deploy"

# Check prerequisites only
ansible-playbook playbook.yml --tags "verify_prerequisites"
```

## Prerequisites

Before using this role, ensure:

1. **CRC is Running**:
   ```bash
   crc status  # Should show "Running"
   ```

2. **Storage Configured**:
   ```bash
   cd ~/openstack/install_yamls
   make crc_storage
   ```

3. **Input Secrets Created**:
   ```bash
   cd ~/openstack/install_yamls
   make input
   ```

## Post-Deployment

After successful deployment:

1. **Check OpenStack Pods**:
   ```bash
   oc get pods -n openstack-operators
   ```

2. **Access OpenStack Services**:
   ```bash
   oc get routes -n openstack
   ```

3. **Manual Control Plane Deployment** (if not automated):
   ```bash
   cd ~/openstack/install_yamls
   eval $(crc oc-env)
   make openstack_deploy
   ```

## Integration Examples

### Sequential Deployment

```yaml
---
- name: Step-by-step OpenStack deployment
  hosts: crc_servers
  become: false
  gather_facts: true
  roles:
    - role: crc
      vars:
        crc_run_openstack: false
    - role: openstack
      vars:
        openstack_run_operators: true
        openstack_run_deploy: false
  
- name: Deploy control plane separately
  hosts: crc_servers
  become: false
  gather_facts: true
  roles:
    - role: openstack
      vars:
        openstack_run_operators: false
        openstack_run_deploy: true
        openstack_deploy_control_plane: true
```

### Multi-Role Deployment

```yaml
---
- name: Complete multi-region setup
  hosts: crc_servers
  become: false
  gather_facts: true
  roles:
    - crc                    # Install CRC
    - openstack             # Install OpenStack operators
    - skmo                  # Configure multi-region networking
```

## Troubleshooting

- **CRC not running**: Ensure CRC is started before running this role
- **Operator installation failures**: Check cluster resources and network connectivity
- **Timeout errors**: Increase `openstack_operators_timeout` for slower systems
- **Permission errors**: Verify user has access to CRC and install_yamls directory

## Monitoring

Check deployment progress:

```bash
# Watch operator pods
oc get pods -n openstack-operators -w

# Check operator logs
oc logs -n openstack-operators -l app=openstack-operator

# Monitor cluster resources
oc top nodes
oc top pods -n openstack-operators
```

## License

Apache-2.0

## Author Information

SKMO Team
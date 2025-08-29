# SKMO (Skupper Multi-OpenStack) Ansible Roles

This repository contains Ansible roles for deploying and managing multi-region OpenStack environments using Skupper for network connectivity.

## Roles

### 1. SKMO Role (`skmo/`)

The main SKMO role for setting up multi-region OpenStack networking using Skupper.

**Features:**
- Multi-region OpenStack deployment coordination
- Skupper network setup and configuration
- Service user management across regions
- Horizon multi-region dashboard configuration
- Workload control-plane overrides

### 2. CRC Role (`crc/`)

Ansible role for deploying CodeReady Containers (CRC) infrastructure using the official install_yamls methodology.

**Features:**
- CRC installation using install_yamls devsetup
- Storage and input configuration
- Configurable resource allocation
- Smart CRC detection and skipping
- Tag-based selective execution

### 3. OpenStack Role (`openstack/`)

Ansible role for deploying OpenStack operators using the official install_yamls methodology.

**Features:**
- OpenStack operators installation
- Optional control plane deployment
- CRC prerequisite verification
- Configurable deployment options
- Integration with CRC role

## Quick Start

### Deploy CRC Infrastructure

```bash
# CRC only (infrastructure setup)
cd examples
ansible-playbook deploy-crc.yml -i inventory.yml
```

### Deploy CRC and OpenStack

```bash
# CRC + OpenStack operators
cd examples
ansible-playbook deploy-crc-and-openstack.yml -i inventory.yml
```

### Deploy OpenStack Only

```bash
# OpenStack operators only (CRC must be running)
cd examples
ansible-playbook deploy-openstack-only.yml -i inventory.yml
```

### Setup SKMO Multi-Region Networking

After setting up OpenStack infrastructure, use the SKMO role for multi-region networking:

```yaml
---
- name: Setup SKMO Multi-Region Networking
  hosts: crc_servers
  roles:
    - role: skmo
      vars:
        skmo_namespaces:
          - name: "{{ server_namespace }}"
            region: "{{ region_name }}"
            is_region_zero: "{{ inventory_hostname == groups['crc_servers'][0] }}"
            server_host: "{{ ansible_host }}"
```

## Repository Structure

```
skmo-role/
├── crc/                     # CRC infrastructure role
│   ├── tasks/
│   ├── defaults/
│   ├── meta/
│   ├── handlers/
│   └── README.md
├── openstack/               # OpenStack operators role
│   ├── tasks/
│   ├── defaults/
│   ├── meta/
│   ├── handlers/
│   └── README.md
├── skmo/                    # Multi-region networking role
│   ├── tasks/
│   ├── templates/
│   ├── defaults/
│   └── README.md
├── examples/
│   ├── deploy-crc.yml              # CRC only
│   ├── deploy-openstack-only.yml   # OpenStack only
│   ├── deploy-crc-and-openstack.yml # Combined
│   ├── inventory.yml               # Example inventory
│   └── ansible.cfg                 # Ansible configuration
└── README.md
```

## Requirements

- **Ansible**: 2.9+
- **Target OS**: Fedora 38+, RHEL/CentOS 8+
- **Resources**: Minimum 12 CPU, 25GB RAM, 100GB disk per server
- **SSH**: Key-based authentication
- **Prerequisites**: install_yamls repository cloned to target servers

## Usage Examples

### Basic CRC Deployment

```bash
cd examples
ansible-playbook deploy-crc.yml -i inventory.yml
```

### Combined CRC and OpenStack

```bash
cd examples
ansible-playbook deploy-crc-and-openstack.yml -i inventory.yml
```

### Custom Resource Allocation

```yaml
---
- name: Deploy with custom resources
  hosts: crc_servers
  roles:
    - role: crc
      vars:
        crc_cpus: 16
        crc_memory: 32768
        crc_disk: 150
    - role: openstack
      vars:
        openstack_deploy_control_plane: true
```

### Selective Execution

```bash
# CRC infrastructure only
ansible-playbook deploy-crc-and-openstack.yml --tags "crc"

# OpenStack operators only
ansible-playbook deploy-crc-and-openstack.yml --tags "openstack_operators"
```

### Complete Multi-Region Setup

1. **Deploy CRC and OpenStack Infrastructure**:
   ```bash
   ansible-playbook deploy-crc-and-openstack.yml -i inventory.yml
   ```

2. **Configure SKMO Multi-Region Networking**:
   ```yaml
   - hosts: crc_servers
     roles:
       - role: skmo
         vars:
           skmo_namespaces:
             - name: openstack
               region: "{{ region_name }}"
               is_region_zero: "{{ inventory_hostname == groups['crc_servers'][0] }}"
   ```

3. **All-in-One Deployment**:
   ```yaml
   - hosts: crc_servers
     roles:
       - crc        # CRC infrastructure
       - openstack  # OpenStack operators
       - skmo       # Multi-region networking
   ```

## Documentation

- [CRC Role Documentation](crc/README.md)
- [OpenStack Role Documentation](openstack/README.md)
- [SKMO Role Documentation](skmo/README.md)
- [Example Playbooks](examples/)

## Contributing

1. Fork the repository
2. Create feature branches
3. Add comprehensive tests
4. Update documentation
5. Submit pull requests

## License

Apache-2.0
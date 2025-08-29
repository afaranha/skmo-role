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

Ansible role for deploying CodeReady Containers (CRC) and OpenStack using the official install_yamls methodology.

**Features:**
- CRC installation using install_yamls devsetup
- OpenStack operator deployment
- Configurable resource allocation
- Step-by-step workflow execution
- Tag-based selective execution

## Quick Start

### Deploy CRC and OpenStack

```bash
# Using the CRC role
cd examples
ansible-playbook deploy-crc.yml -i inventory.yml
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
├── crc/                     # CRC deployment role
│   ├── tasks/
│   ├── defaults/
│   ├── meta/
│   ├── handlers/
│   └── README.md
├── skmo/                    # Main SKMO role
│   ├── tasks/
│   ├── templates/
│   ├── defaults/
│   └── README.md
├── examples/
│   ├── deploy-crc.yml       # CRC deployment playbook
│   ├── inventory.yml        # Example inventory
│   └── ansible.cfg          # Ansible configuration
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

### Custom Resource Allocation

```yaml
---
- name: Deploy CRC with custom resources
  hosts: crc_servers
  roles:
    - role: crc
      vars:
        crc_cpus: 16
        crc_memory: 32768
        crc_disk: 150
```

### Selective Step Execution

```bash
# Run only CRC installation
ansible-playbook deploy-crc.yml -i inventory.yml --tags "make_crc"

# Skip CRC installation, run other steps
ansible-playbook deploy-crc.yml -i inventory.yml --skip-tags "make_crc"
```

### Complete Multi-Region Setup

1. **Deploy CRC Infrastructure**:
   ```bash
   ansible-playbook deploy-crc.yml -i inventory.yml
   ```

2. **Configure SKMO Networking**:
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

## Documentation

- [CRC Role Documentation](crc/README.md)
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
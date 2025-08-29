# SKMO (Skupper Multi-OpenStack) Ansible Role

This repository contains an Ansible role for deploying and managing multi-region OpenStack environments using Skupper for network connectivity.

## SKMO Role (`skmo/`)

The main SKMO role for setting up multi-region OpenStack networking using Skupper.

**Features:**
- Multi-region OpenStack deployment coordination
- Skupper network setup and configuration
- Service user management across regions
- Horizon multi-region dashboard configuration
- Workload control-plane overrides

## Simple Install_yamls Workflow

This repository also provides a simple, direct workflow for setting up CRC and OpenStack using the official install_yamls methodology:

```bash
cd examples/crc-deployment
ansible-playbook install-yamls-workflow.yml -i inventory.yml
```

This workflow follows the install_yamls documentation exactly:
1. `make crc` - Install and start CRC
2. `make crc_storage` - Configure persistent storage
3. `make input` - Create input secrets
4. `make openstack` - Install OpenStack operators

## Repository Structure

```
skmo-role/
├── skmo/                    # Main SKMO role
│   ├── tasks/
│   ├── templates/
│   ├── defaults/
│   └── ...
├── examples/
│   └── crc-deployment/      # Simple install_yamls workflow
│       ├── install-yamls-workflow.yml
│       ├── inventory.yml
│       └── ansible.cfg
└── README.md
```

## Requirements

- **Ansible**: 2.9+
- **Target OS**: Fedora 38+, RHEL/CentOS 8+
- **Resources**: Minimum 12 CPU, 25GB RAM, 100GB disk per server
- **SSH**: Key-based authentication
- **Prerequisites**: install_yamls repository cloned to `/home/fedora/openstack/install_yamls`

## Usage

### Install_yamls Workflow

1. Clone install_yamls repository on target servers
2. Configure inventory with your servers
3. Run the workflow:

```bash
cd examples/crc-deployment
ansible-playbook install-yamls-workflow.yml -i inventory.yml
```

### SKMO Multi-Region Setup

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

## Contributing

1. Fork the repository
2. Create feature branches
3. Add comprehensive tests
4. Update documentation
5. Submit pull requests

## License

Apache License 2.0
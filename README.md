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

**NEW**: Comprehensive role for deploying CodeReady Containers (CRC) with optional OpenStack across multiple servers.

**Features:**
- ✅ Multi-server CRC deployment
- ✅ Automated OpenStack deployment using install_yamls
- ✅ Network isolation for multi-region setups
- ✅ Resource optimization and validation
- ✅ Generated access and management scripts
- ✅ Integration-ready for SKMO networking

## Quick Start

### Deploy CRC Infrastructure + OpenStack

```bash
# Multi-server deployment
cd examples/crc-deployment
./deploy.sh deploy-multi-server.yml

# Single server deployment  
./deploy.sh deploy-single-server.yml

# CRC only (no OpenStack)
./deploy.sh deploy-crc-only.yml
```

### Setup SKMO Multi-Region Networking

```bash
cd examples/afariasa-deployment
ansible-playbook playbook.yml
```

## Complete Multi-Region Setup

For a complete multi-region OpenStack deployment with networking:

1. **Deploy CRC + OpenStack Infrastructure**
   ```bash
   cd examples/crc-deployment
   ./deploy.sh deploy-multi-server.yml
   ```

2. **Configure SKMO Networking**
   ```bash
   cd examples/afariasa-deployment
   ansible-playbook playbook.yml
   ```

## Repository Structure

```
skmo-role/
├── skmo/                    # Main SKMO role
│   ├── tasks/
│   ├── templates/
│   ├── defaults/
│   └── ...
├── crc/                     # CRC deployment role
│   ├── tasks/
│   ├── templates/
│   ├── defaults/
│   └── README.md
├── examples/
│   ├── crc-deployment/      # CRC deployment examples
│   │   ├── deploy-multi-server.yml
│   │   ├── inventory.yml
│   │   └── deploy.sh
│   └── afariasa-deployment/ # SKMO examples
│       ├── playbook.yml
│       └── inventory.yml
└── README.md
```

## Integration Example

Deploy both CRC infrastructure and SKMO networking in one playbook:

```yaml
---
- name: Deploy CRC Infrastructure
  hosts: crc_servers
  roles:
    - role: crc
      vars:
        crc_deploy_openstack: true
        crc_operator_namespace: "openstack-operators"

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

## Requirements

- **Ansible**: 2.9+
- **Target OS**: Fedora 38+, RHEL/CentOS 8+
- **Resources**: Minimum 4 CPU, 9GB RAM, 31GB disk per server
- **SSH**: Key-based authentication

## Documentation

- [CRC Role Documentation](crc/README.md)
- [SKMO Examples](examples/)
- [Deployment Scripts](examples/crc-deployment/)

## Contributing

1. Fork the repository
2. Create feature branches for each role
3. Add comprehensive tests
4. Update documentation
5. Submit pull requests

## License

Apache License 2.0

## Support

- GitHub Issues for bugs and feature requests
- Documentation in role-specific README files
- Example deployments in `examples/` directory
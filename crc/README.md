# CRC (CodeReady Containers) Ansible Role

This Ansible role automates the deployment of CodeReady Containers (CRC) with optional OpenStack deployment across multiple servers. Part of the SKMO (Skupper Multi-OpenStack) project.

## Features

- ✅ **Multi-server deployment** - Deploy CRC on any number of servers
- ✅ **OpenStack integration** - Optional OpenStack deployment using install_yamls
- ✅ **Network isolation** - Configure different network ranges per server/region
- ✅ **Resource optimization** - Configurable CPU, memory, and disk allocation
- ✅ **Access scripts** - Auto-generated management and access scripts
- ✅ **Validation** - Built-in deployment validation and health checks
- ✅ **Error handling** - Comprehensive error handling and recovery

## Requirements

- **Ansible**: 2.9+
- **Target OS**: Fedora 38+, RHEL/CentOS 8+
- **Architecture**: x86_64, aarch64
- **Resources**: Minimum 4 CPU, 9GB RAM, 31GB disk per server
- **SSH Access**: SSH key-based authentication to target servers

## Quick Start

### 1. Basic Multi-Server Deployment

```bash
cd examples/crc-deployment
./deploy.sh deploy-multi-server.yml
```

### 2. Single Server Deployment

```bash
cd examples/crc-deployment
./deploy.sh deploy-single-server.yml
```

### 3. CRC Only (No OpenStack)

```bash
cd examples/crc-deployment
./deploy.sh deploy-crc-only.yml
```

## Role Variables

### Core Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `crc_version` | `"2.43.0"` | CRC version to install |
| `crc_user` | `"fedora"` | User to run CRC (non-root) |
| `crc_memory` | `"25600"` | Memory allocation (MB) |
| `crc_cpus` | `"12"` | CPU cores |
| `crc_disk_size` | `"100"` | Disk size (GB) |

### OpenStack Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `crc_deploy_openstack` | `true` | Deploy OpenStack |
| `crc_operator_namespace` | `"openstack-operators"` | Operator namespace |
| `crc_workload_namespace` | `"openstack"` | Workload namespace |
| `crc_network_isolation` | `false` | Enable network isolation |
| `crc_network_ranges` | `[]` | Custom network ranges |

### Advanced Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `crc_create_access_scripts` | `true` | Create access scripts |
| `crc_setup_sudoers` | `true` | Configure sudo access |
| `crc_validate_deployment` | `true` | Run validation |
| `crc_log_level` | `"info"` | Logging level |

## Inventory Configuration

### Multi-Server Example

```yaml
# inventory.yml
crc_servers:
  hosts:
    region-1:
      ansible_host: 10.0.79.173
      ansible_user: fedora
      region_name: region-1
      server_namespace: region-1-openstack
      network_ranges:
        - "172.17.0.0/16"
        - "172.18.0.0/16"
    
    region-2:
      ansible_host: 10.0.79.110
      ansible_user: fedora
      region_name: region-2
      server_namespace: region-2-openstack
      network_ranges:
        - "172.27.0.0/16"
        - "172.28.0.0/16"
```

## Playbook Examples

### Complete Multi-Region Setup

```yaml
---
- name: Deploy CRC + OpenStack Multi-Region
  hosts: crc_servers
  become: yes
  vars:
    crc_deploy_openstack: true
    crc_operator_namespace: "openstack-operators"
    crc_network_isolation: true
  roles:
    - role: crc
```

### Development Environment

```yaml
---
- name: Deploy CRC Development Environment
  hosts: localhost
  vars:
    crc_memory: "16384"
    crc_cpus: "8"
    crc_deploy_openstack: false
  roles:
    - role: crc
```

## Generated Access Scripts

After deployment, the following scripts are created in `/home/{{ crc_user }}/`:

| Script | Purpose |
|--------|---------|
| `crc-access.sh` | CRC cluster access and status |
| `openstack-access.sh` | OpenStack services access |
| `manage-crc.sh` | CRC management (start/stop/restart) |
| `setup-env.sh` | Environment setup |

### Usage Examples

```bash
# SSH to server
ssh fedora@10.0.79.173

# Access CRC cluster
./crc-access.sh

# Access OpenStack services
./openstack-access.sh

# Manage CRC cluster
./manage-crc.sh status
./manage-crc.sh restart
```

## Network Configuration

The role supports network isolation for multi-region deployments:

```yaml
# Region 1
network_ranges:
  - "172.17.0.0/16"  # Internal API
  - "172.18.0.0/16"  # Storage
  - "172.19.0.0/16"  # Tenant
  - "172.20.0.0/16"  # External

# Region 2  
network_ranges:
  - "172.27.0.0/16"  # Internal API
  - "172.28.0.0/16"  # Storage
  - "172.29.0.0/16"  # Tenant
  - "172.30.0.0/16"  # External
```

## Deployment Validation

The role includes built-in validation:

- ✅ CRC cluster health
- ✅ OpenShift API access
- ✅ Node readiness
- ✅ OpenStack pod status
- ✅ Service availability

## Troubleshooting

### Common Issues

1. **Insufficient Resources**
   ```bash
   # Check available resources
   free -h
   nproc
   df -h
   ```

2. **SSH Connection Issues**
   ```bash
   # Test connectivity
   ansible crc_servers -m ping
   ```

3. **CRC Start Failures**
   ```bash
   # Check CRC logs
   ./manage-crc.sh logs
   ```

### Log Locations

- CRC logs: `~/.crc/crc.log`
- Deployment logs: `/tmp/crc-deployment-*.log`
- Ansible logs: As configured in ansible.cfg

## Integration with SKMO

This CRC role is designed to work with the SKMO role for multi-region networking:

```yaml
---
- name: Deploy CRC Infrastructure
  hosts: crc_servers
  roles:
    - role: crc

- name: Setup SKMO Networking
  hosts: crc_servers
  roles:
    - role: skmo
      vars:
        skmo_namespaces:
          - name: "{{ server_namespace }}"
            region: "{{ region_name }}"
            is_region_zero: "{{ inventory_hostname == groups['crc_servers'][0] }}"
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

## License

Apache License 2.0

## Support

For issues and questions:
- GitHub Issues: [SKMO Repository](https://github.com/your-org/skmo-role)
- Documentation: [CRC Documentation](https://crc.dev/)
- OpenStack K8s: [install_yamls](https://github.com/openstack-k8s-operators/install_yamls)
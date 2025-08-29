# CRC Role

This Ansible role deploys CodeReady Containers (CRC) and OpenStack using the official install_yamls methodology.

## Description

This role follows the install_yamls documentation exactly to set up CRC and OpenStack operators. It executes the standard workflow:

1. `make crc` - Install and start CRC
2. `make crc_storage` - Configure persistent storage
3. `make input` - Create input secrets
4. `make openstack` - Install OpenStack operators

## Requirements

- **Target OS**: Fedora 38+, RHEL/CentOS 8+
- **Resources**: Minimum 12 CPU, 25GB RAM, 100GB disk
- **Prerequisites**: 
  - install_yamls repository cloned to `/home/fedora/openstack/install_yamls`
  - Pull secret file available at `/home/fedora/pull-secret.txt`
- **SSH**: Key-based authentication to target servers

## Role Variables

### Default Variables (crc/defaults/main.yml)

```yaml
# User configuration
crc_user: fedora

# Resource allocation
crc_cpus: 12
crc_memory: 25600  # MB
crc_disk: 100      # GB

# Path configuration
crc_install_yamls_path: "/home/{{ crc_user }}/openstack/install_yamls"
crc_devsetup_path: "{{ crc_install_yamls_path }}/devsetup"
crc_pull_secret_path: "/home/{{ crc_user }}/pull-secret.txt"
crc_bin_path: "/home/{{ crc_user }}/bin"

# Timeout settings (seconds)
crc_install_timeout: 2400  # 40 minutes
crc_storage_timeout: 300   # 5 minutes
crc_input_timeout: 300     # 5 minutes
crc_openstack_timeout: 1800 # 30 minutes

# Step execution control
crc_run_install: true
crc_run_storage: true
crc_run_input: true
crc_run_openstack: true

# Skip installation if CRC is already running
crc_skip_if_running: true
```

## Smart CRC Detection

The role automatically checks if CRC is already deployed and running before attempting installation. This prevents unnecessary reinstallation and saves time:

- **Automatic Detection**: Checks CRC status before installation
- **Smart Skipping**: Skips `make crc` if CRC is already running
- **Configurable**: Set `crc_skip_if_running: false` to force reinstallation
- **Detailed Logging**: Shows current CRC status and installation decisions

## Dependencies

None

## Example Playbook

### Basic Usage

```yaml
---
- name: Deploy CRC and OpenStack
  hosts: crc_servers
  become: false
  gather_facts: true
  roles:
    - crc
```

### Advanced Usage with Custom Variables

```yaml
---
- name: Deploy CRC with custom configuration
  hosts: crc_servers
  become: false
  gather_facts: true
  roles:
    - role: crc
      vars:
        crc_cpus: 16
        crc_memory: 32768
        crc_disk: 150
        crc_run_openstack: false  # Only install CRC, skip OpenStack
```

### Selective Step Execution

```yaml
---
- name: Run only storage and input steps
  hosts: crc_servers
  become: false
  gather_facts: true
  roles:
    - role: crc
      vars:
        crc_run_install: false
        crc_run_storage: true
        crc_run_input: true
        crc_run_openstack: false
```

### Force CRC Reinstallation

```yaml
---
- name: Force CRC reinstallation even if running
  hosts: crc_servers
  become: false
  gather_facts: true
  roles:
    - role: crc
      vars:
        crc_skip_if_running: false  # Force reinstallation
```

## Tags

The role supports the following tags for selective execution:

- `check_crc` - Check current CRC status
- `make_crc` - CRC installation step (includes check)
- `verify_crc` - CRC status verification
- `make_crc_storage` - Storage configuration step  
- `make_input` - Input secrets creation step
- `make_openstack` - OpenStack operators installation step
- `summary` - Final status display

### Example Tag Usage

```bash
# Check CRC status only
ansible-playbook playbook.yml --tags "check_crc"

# Run only CRC installation (includes status check)
ansible-playbook playbook.yml --tags "make_crc"

# Run storage and input steps only
ansible-playbook playbook.yml --tags "make_crc_storage,make_input"

# Skip CRC installation, run everything else
ansible-playbook playbook.yml --skip-tags "make_crc"
```

## Inventory Example

```yaml
crc_servers:
  hosts:
    server1:
      ansible_host: 10.0.1.100
      ansible_user: fedora
    server2:
      ansible_host: 10.0.1.101
      ansible_user: fedora
```

## Prerequisites Setup

Before using this role, ensure the following are set up on target servers:

1. **Install_yamls Repository**:
   ```bash
   git clone https://github.com/openstack-k8s-operators/install_yamls.git /home/fedora/openstack/install_yamls
   ```

2. **Pull Secret**: Place your OpenShift pull secret at `/home/fedora/pull-secret.txt`

3. **System Resources**: Ensure sufficient CPU, memory, and disk space

## Post-Deployment

After successful deployment, you can:

1. **Access CRC**:
   ```bash
   ssh fedora@<server-ip>
   export PATH="/home/fedora/bin:$PATH"
   crc status
   crc console --credentials
   ```

2. **Deploy OpenStack Control Plane**:
   ```bash
   cd ~/openstack/install_yamls
   eval $(crc oc-env)
   make openstack_deploy
   ```

3. **Access OpenShift Console**: https://console-openshift-console.apps-crc.testing

## Troubleshooting

- **CRC installation failures**: Check system resources and pull secret
- **Storage configuration issues**: Verify CRC is running before storage setup
- **Operator installation problems**: Check network connectivity and cluster status
- **Timeout errors**: Increase timeout values for slower systems

## License

Apache-2.0

## Author Information

SKMO Team
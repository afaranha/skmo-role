# SKMO + CRC Deployment Guide

## 🎯 Overview

This repository now provides comprehensive Ansible automation for:

1. **CRC (CodeReady Containers)** deployment across multiple servers
2. **OpenStack** deployment using official install_yamls
3. **SKMO (Skupper Multi-OpenStack)** multi-region networking

## 🚀 Quick Deployment Commands

### Option 1: Multi-Server CRC + OpenStack
```bash
cd /root/ai-workspace/skmo-role/examples/crc-deployment
./deploy.sh deploy-multi-server.yml
```

### Option 2: Complete Multi-Region Setup (CRC + OpenStack + SKMO)
```bash
cd /root/ai-workspace/skmo-role
ansible-playbook examples/complete-deployment.yml -i examples/crc-deployment/inventory.yml
```

### Option 3: Original Deployment (from workspace root)
```bash
cd /root/ai-workspace
./deploy-everything.sh
```

## 📁 Repository Structure

```
/root/ai-workspace/skmo-role/
├── crc/                           # NEW: CRC Role
│   ├── tasks/                     # CRC deployment tasks
│   │   ├── main.yml              # Main task orchestration
│   │   ├── prerequisites.yml     # System setup
│   │   ├── install.yml           # CRC installation
│   │   ├── configure.yml         # CRC configuration
│   │   ├── start.yml             # CRC startup
│   │   ├── openstack.yml         # OpenStack deployment
│   │   ├── access_scripts.yml    # Script generation
│   │   ├── validate_deployment.yml # Validation
│   │   └── cleanup.yml           # Cleanup tasks
│   ├── templates/                # Script templates
│   │   ├── crc_access.sh.j2      # CRC access script
│   │   ├── openstack_access.sh.j2 # OpenStack access
│   │   ├── manage_crc.sh.j2      # CRC management
│   │   └── setup_env.sh.j2       # Environment setup
│   ├── defaults/main.yml         # Default variables
│   ├── handlers/main.yml         # Event handlers
│   ├── meta/main.yml            # Role metadata
│   └── README.md                # CRC role documentation
├── skmo/                         # Original SKMO Role
│   ├── tasks/                   # SKMO networking tasks
│   ├── templates/               # SKMO templates
│   └── defaults/main.yml        # SKMO defaults
├── examples/
│   ├── crc-deployment/          # NEW: CRC Examples
│   │   ├── deploy-multi-server.yml  # Multi-server playbook
│   │   ├── deploy-single-server.yml # Single server playbook
│   │   ├── deploy-crc-only.yml     # CRC only (no OpenStack)
│   │   ├── inventory.yml           # Server inventory
│   │   ├── ansible.cfg            # Ansible configuration
│   │   └── deploy.sh              # Deployment script
│   └── complete-deployment.yml     # Combined CRC + SKMO
└── README.md                       # Main documentation
```

## 🔧 Configuration Examples

### Multi-Server Inventory

```yaml
# examples/crc-deployment/inventory.yml
crc_servers:
  hosts:
    afariasa-region-1:
      ansible_host: 10.0.79.173
      ansible_user: fedora
      region_name: region-1
      server_namespace: afariasa-region-1-openstack
      network_ranges:
        - "172.17.0.0/16"
        - "172.18.0.0/16"
    
    afariasa-region-2:
      ansible_host: 10.0.79.110
      ansible_user: fedora
      region_name: region-2
      server_namespace: afariasa-region-2-openstack
      network_ranges:
        - "172.27.0.0/16"
        - "172.28.0.0/16"
```

### Role Variables

```yaml
# CRC Configuration
crc_version: "2.43.0"
crc_user: "fedora"
crc_memory: "25600"     # 25GB RAM
crc_cpus: "12"          # 12 CPU cores
crc_disk_size: "100"    # 100GB disk
crc_deploy_openstack: true
crc_operator_namespace: "openstack-operators"

# Per-server variables
crc_workload_namespace: "{{ server_namespace }}"
crc_network_ranges: "{{ network_ranges }}"
```

## 📋 Deployment Options

### 1. CRC + OpenStack Only

```bash
cd examples/crc-deployment
./deploy.sh deploy-multi-server.yml
```

**What it deploys:**
- ✅ CRC on both servers (10.0.79.173, 10.0.79.110)
- ✅ OpenStack using install_yamls
- ✅ Network isolation per region
- ✅ Access scripts for management

### 2. Complete Multi-Region Setup

```bash
ansible-playbook examples/complete-deployment.yml
```

**What it deploys:**
- ✅ Everything from Option 1
- ✅ SKMO networking between regions
- ✅ Skupper connectivity
- ✅ Multi-region Horizon dashboard

### 3. Development Environment

```bash
./deploy.sh deploy-single-server.yml
```

**What it deploys:**
- ✅ Single CRC instance
- ✅ Reduced resource requirements
- ✅ Perfect for testing

## 🎯 Generated Access Scripts

After deployment, each server gets these scripts in `/home/fedora/`:

| Script | Purpose |
|--------|---------|
| `./crc-access.sh` | CRC cluster status and access |
| `./openstack-access.sh` | OpenStack services and endpoints |
| `./manage-crc.sh` | CRC management (start/stop/restart) |
| `./setup-env.sh` | Environment setup for development |

### Usage Examples

```bash
# SSH to server
ssh fedora@10.0.79.173

# Check CRC status
./crc-access.sh

# Access OpenStack
./openstack-access.sh

# Restart CRC if needed
./manage-crc.sh restart
```

## 🌐 Access Information

### CRC Console
- **URL**: https://console-openshift-console.apps-crc.testing
- **Username**: kubeadmin
- **Password**: password

### OpenStack Access
```bash
# Port forward Horizon dashboard
kubectl port-forward -n <namespace> service/horizon 8080:80
# Visit: http://localhost:8080
```

## ✅ Validation

The deployment includes automatic validation:
- CRC cluster health
- OpenShift API accessibility
- Node readiness status
- OpenStack pod deployment
- Service endpoint availability

## 🔄 Integration with Original Scripts

The new CRC role is fully compatible with existing deployment scripts:

```bash
# Original deployment still works
cd /root/ai-workspace
./deploy-everything.sh

# New role-based deployment
cd /root/ai-workspace/skmo-role/examples/crc-deployment
./deploy.sh
```

## 🎉 Success Criteria

Deployment is successful when:

1. **CRC Status**: `crc status` shows "Running"
2. **OpenShift Access**: `oc get nodes` returns ready nodes
3. **OpenStack Pods**: Multiple running pods in workload namespace
4. **Access Scripts**: All 4 scripts created and executable
5. **Network Isolation**: Different IP ranges per region

## 🆘 Troubleshooting

### Check CRC Status
```bash
ssh fedora@<server-ip>
./manage-crc.sh status
```

### View Deployment Logs
```bash
tail -f /tmp/crc-deployment-*.log
```

### Manual Recovery
```bash
# If CRC fails to start
./manage-crc.sh restart

# If OpenStack deployment fails
cd /home/fedora/openstack/install_yamls
make openstack_prep
make openstack
```

## 📞 Support

- **CRC Issues**: Check `./manage-crc.sh logs`
- **OpenStack Issues**: Check `oc get pods -n <namespace>`
- **Network Issues**: Verify SSH connectivity and firewall rules
- **Ansible Issues**: Check `/tmp/crc-deployment-*.log`

## 🎯 Next Steps

After successful deployment:

1. **Test OpenStack Services**: Access Horizon dashboard
2. **Deploy Workloads**: Use oc CLI for Kubernetes workloads
3. **Configure SKMO**: Enable multi-region networking
4. **Monitor Resources**: Check CPU/memory usage
5. **Scale Services**: Add more regions as needed
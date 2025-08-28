#!/bin/bash

# CRC Deployment Script using SKMO CRC Role
# Usage: ./deploy.sh [playbook]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Default playbook
PLAYBOOK="${1:-deploy-multi-server.yml}"

echo "🚀 CRC Deployment using SKMO Role"
echo "================================="
echo ""
echo "Playbook: $PLAYBOOK"
echo "Inventory: inventory.yml"
echo ""

# Available playbooks
if [ "$1" = "--list" ]; then
    echo "Available playbooks:"
    echo "  deploy-multi-server.yml      - Deploy CRC + OpenStack on multiple servers"
    echo "  deploy-single-server.yml     - Deploy CRC + OpenStack on single server"
    echo "  deploy-crc-only.yml          - Deploy CRC only (no OpenStack)"
    echo "  deploy-advanced-openstack.yml - Deploy CRC + Advanced OpenStack (Enterprise)"
    echo ""
    echo "Usage: $0 [playbook-name]"
    exit 0
fi

# Validate playbook exists
if [ ! -f "$PLAYBOOK" ]; then
    echo "❌ Playbook not found: $PLAYBOOK"
    echo ""
    echo "Run '$0 --list' to see available playbooks"
    exit 1
fi

# Check prerequisites
if ! command -v ansible-playbook &> /dev/null; then
    echo "❌ Ansible is not installed"
    exit 1
fi

# Test connectivity
echo "🔍 Testing connectivity..."
if ansible crc_servers -m ping -o; then
    echo "✅ Connectivity confirmed"
else
    echo "❌ Connectivity failed"
    exit 1
fi

echo ""
echo "📋 Deployment Details:"
ansible-inventory --list | jq '.crc_servers.hosts' 2>/dev/null || echo "Multiple servers configured"

echo ""
read -p "Continue with deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    exit 0
fi

# Start deployment
START_TIME=$(date +%s)
echo ""
echo "🎯 Starting CRC deployment..."
echo "Log: /tmp/crc-deployment-$(date +%Y%m%d-%H%M%S).log"

# Run deployment
ansible-playbook "$PLAYBOOK" -v | tee "/tmp/crc-deployment-$(date +%Y%m%d-%H%M%S).log"

# Calculate time
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo ""
echo "🎉 DEPLOYMENT COMPLETE!"
echo "====================="
echo ""
echo "⏱️  Duration: ${MINUTES}m ${SECONDS}s"
echo ""
echo "🔧 Access your deployments:"
ansible crc_servers -a "ls -la /home/fedora/*.sh" -o 2>/dev/null || echo "Check individual servers for access scripts"
echo ""
echo "💡 Next steps:"
echo "  1. SSH to each server"
echo "  2. Run ./crc-access.sh for cluster access"
echo "  3. Run ./openstack-access.sh for OpenStack (if deployed)"
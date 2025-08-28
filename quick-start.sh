#!/bin/bash

# SKMO + CRC Quick Start Script
# Usage: ./quick-start.sh [deployment-type]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🚀 SKMO + CRC Quick Start"
echo "========================="
echo ""

# Show available deployment options
show_options() {
    echo "Available deployment options:"
    echo ""
    echo "1. multi-server    - Deploy CRC + OpenStack on multiple servers"
    echo "2. single-server   - Deploy CRC + OpenStack on single server"
    echo "3. crc-only        - Deploy CRC only (no OpenStack)"
    echo "4. advanced        - Deploy CRC + Advanced OpenStack (Enterprise-grade)"
    echo "5. complete        - Deploy CRC + OpenStack + SKMO networking"
    echo ""
    echo "Usage:"
    echo "  ./quick-start.sh multi-server"
    echo "  ./quick-start.sh single-server"
    echo "  ./quick-start.sh crc-only"
    echo "  ./quick-start.sh advanced"
    echo "  ./quick-start.sh complete"
    echo ""
}

# Default to showing options if no argument
DEPLOYMENT_TYPE="${1:-help}"

case "$DEPLOYMENT_TYPE" in
    "multi-server")
        echo "🎯 Deploying CRC + OpenStack on multiple servers..."
        cd examples/crc-deployment
        ./deploy.sh deploy-multi-server.yml
        ;;
    "single-server")
        echo "🎯 Deploying CRC + OpenStack on single server..."
        cd examples/crc-deployment
        ./deploy.sh deploy-single-server.yml
        ;;
    "crc-only")
        echo "🎯 Deploying CRC only (no OpenStack)..."
        cd examples/crc-deployment
        ./deploy.sh deploy-crc-only.yml
        ;;
    "advanced")
        echo "🎯 Deploying CRC + Advanced OpenStack (Enterprise-grade)..."
        cd examples/crc-deployment
        ./deploy.sh deploy-advanced-openstack.yml
        ;;
    "complete")
        echo "🎯 Deploying complete CRC + OpenStack + SKMO setup..."
        ansible-playbook examples/complete-deployment.yml -i examples/crc-deployment/inventory.yml
        ;;
    "help"|*)
        show_options
        exit 0
        ;;
esac

echo ""
echo "🎉 Deployment initiated!"
echo ""
echo "📊 Monitor progress:"
echo "  tail -f /tmp/crc-deployment-*.log"
echo ""
echo "🔧 After completion, access your deployment:"
echo "  ssh fedora@<server-ip>"
echo "  ./crc-access.sh"
echo "  ./openstack-access.sh"
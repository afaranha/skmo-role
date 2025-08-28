# Branch Organization

## Repository Structure

This repository follows a feature branch workflow for organizing different capabilities:

### Branches

#### `main` branch
- **Purpose**: Stable, production-ready SKMO role
- **Content**: Original SKMO (Skupper Multi-OpenStack) Ansible role
- **Status**: Synchronized with upstream/origin
- **Use Case**: Production deployments of SKMO networking

#### `feature/crc-deployment` branch  
- **Purpose**: CRC (CodeReady Containers) deployment capabilities
- **Content**: Complete CRC deployment automation + SKMO integration
- **Status**: Ready for testing and review
- **Use Case**: Automated CRC + OpenStack + SKMO deployments

## Quick Start

### For SKMO-only deployments (main branch):
```bash
git checkout main
# Use original SKMO role for networking setup
```

### For CRC + OpenStack deployments (feature branch):
```bash
git checkout feature/crc-deployment
./quick-start.sh multi-server    # Deploy CRC + OpenStack on multiple servers
./quick-start.sh single-server   # Deploy CRC + OpenStack on single server  
./quick-start.sh crc-only        # Deploy CRC only
./quick-start.sh complete        # Deploy CRC + OpenStack + SKMO networking
```

## Development Workflow

1. **New features**: Create feature branches from `main`
2. **CRC enhancements**: Work on `feature/crc-deployment` branch
3. **Successful changes**: Commit immediately to preserve working state
4. **Testing**: Use feature branches for validation
5. **Integration**: Merge stable features back to `main`

## Current Status

- ✅ **Main branch**: Clean, original SKMO role
- ✅ **Feature branch**: Complete CRC deployment system
- ✅ **One-command deployments**: Fully functional
- ✅ **Documentation**: Comprehensive guides available
- ✅ **Integration**: CRC + SKMO working together

Last updated: $(date)
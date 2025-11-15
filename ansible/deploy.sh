#!/bin/bash
# GokBoru Deployment Script
# This script automates the deployment process

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Print banner
echo -e "${BLUE}"
echo "╔════════════════════════════════════════╗"
echo "║   GokBoru Deployment Script           ║"
echo "║   Deploying React App to AWS EC2      ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"

# Check if we're in the correct directory
if [ ! -f "ansible.cfg" ]; then
    print_error "Please run this script from the ansible/ directory"
    exit 1
fi

print_info "Starting pre-deployment checks..."

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    print_error "Ansible is not installed. Please install it first:"
    echo "sudo apt update && sudo apt install ansible -y"
    exit 1
fi

print_success "Ansible is installed: $(ansible --version | head -n1)"

# Check if SSH key exists
if [ ! -f "ansiblekey.pem" ]; then
    print_error "SSH key 'ansiblekey.pem' not found in current directory!"
    echo ""
    print_warning "Please copy your SSH key to this directory:"
    echo "  cp /path/to/your/ansiblekey.pem ."
    echo "  chmod 400 ansiblekey.pem"
    exit 1
fi

# Check SSH key permissions
KEY_PERMS=$(stat -c %a ansiblekey.pem 2>/dev/null || stat -f %A ansiblekey.pem)
if [ "$KEY_PERMS" != "400" ] && [ "$KEY_PERMS" != "600" ]; then
    print_warning "SSH key has incorrect permissions ($KEY_PERMS). Fixing..."
    chmod 400 ansiblekey.pem
    print_success "Key permissions set to 400"
fi

print_success "SSH key found with correct permissions"

# Test connection
print_info "Testing connection to EC2 servers..."
if ansible-playbook test-connection.yml -v > /dev/null 2>&1; then
    print_success "Connection test passed!"
else
    print_warning "Connection test had some issues. Continuing anyway..."
    print_info "If deployment fails, check:"
    echo "  1. EC2 instances are running"
    echo "  2. Security groups allow SSH (port 22)"
    echo "  3. IP addresses are correct"
fi

# Ask for confirmation
echo ""
print_warning "Ready to deploy to the following servers:"
echo "  • 15.207.112.73"
echo "  • 13.203.216.177"
echo ""
read -p "Continue with deployment? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Deployment cancelled"
    exit 0
fi

# Start deployment
print_info "Starting deployment..."
echo ""

# Run the deployment playbook
if ansible-playbook deploy.yml; then
    echo ""
    print_success "═══════════════════════════════════════"
    print_success "   Deployment completed successfully!   "
    print_success "═══════════════════════════════════════"
    echo ""
    print_info "Your website is now available at:"
    echo "  🌐 http://15.207.112.73"
    echo "  🌐 http://13.203.216.177"
    echo ""
    print_info "Verifying deployment..."
    
    # Test if websites are responding
    if curl -s -o /dev/null -w "%{http_code}" http://15.207.112.73 | grep -q "200\|301\|302"; then
        print_success "Server 1 (15.207.112.73) is responding!"
    else
        print_warning "Server 1 might not be ready yet. Wait a few seconds and try accessing it."
    fi
    
    if curl -s -o /dev/null -w "%{http_code}" http://13.203.216.177 | grep -q "200\|301\|302"; then
        print_success "Server 2 (13.203.216.177) is responding!"
    else
        print_warning "Server 2 might not be ready yet. Wait a few seconds and try accessing it."
    fi
    
else
    echo ""
    print_error "═══════════════════════════════════════"
    print_error "   Deployment failed!                  "
    print_error "═══════════════════════════════════════"
    echo ""
    print_info "Troubleshooting steps:"
    echo "  1. Run with verbose mode: ansible-playbook deploy.yml -vvv"
    echo "  2. Check server connectivity: ansible-playbook test-connection.yml"
    echo "  3. SSH manually: ssh -i ansiblekey.pem ubuntu@15.207.112.73"
    exit 1
fi

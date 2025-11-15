# Ansible Deployment for GokBoru React Website

This directory contains Ansible playbooks and roles to deploy the GokBoru React website to AWS EC2 instances.

## Prerequisites

1. **Ansible installed** on your control machine (local machine)
2. **SSH key** (`ansiblekey.pem`) placed in the `ansible/` directory
3. **EC2 instances** running Ubuntu with SSH access enabled
4. Python 3 installed on the EC2 instances

## Directory Structure

```
ansible/
├── ansible.cfg           # Ansible configuration
├── inventory.yml         # EC2 hosts inventory
├── deploy.yml           # Main deployment playbook
├── test-connection.yml  # Connection test playbook
└── roles/
    └── webserver/
        ├── tasks/
        │   └── main.yml          # Main tasks
        ├── handlers/
        │   └── main.yml          # Handler tasks
        └── templates/
            └── nginx-site.conf.j2 # Nginx configuration template
```

## Installation Steps

### 1. Install Ansible

**On Ubuntu/WSL:**

```bash
sudo apt update
sudo apt install software-properties-common -y
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y
```

**Verify installation:**

```bash
ansible --version
```

### 2. Setup SSH Key

Make sure `ansiblekey.pem` is in the `ansible/` directory with correct permissions:

```bash
cd ansible
chmod 400 ansiblekey.pem
```

### 3. Test Connection

Test connectivity to your EC2 instances:

```bash
cd ansible
ansible-playbook test-connection.yml
```

## Deployment

### Deploy to All Servers

Run the main deployment playbook:

```bash
cd ansible
ansible-playbook deploy.yml
```

### Deploy to Specific Server

Deploy to a single server:

```bash
ansible-playbook deploy.yml --limit ec2-server-1
```

### Check Deployment Status

After deployment, verify the website is running:

```bash
# Test on server 1
curl http://15.207.112.73

# Test on server 2
curl http://13.203.216.177
```

## What the Playbook Does

1. **Installs dependencies:**

   - Nginx web server
   - Node.js 18.x
   - npm
   - Git and other utilities

2. **Deploys the application:**

   - Copies the React application files to `/var/www/gokboru/`
   - Installs npm dependencies
   - Builds the React application (`npm run build`)

3. **Configures Nginx:**

   - Sets up a virtual host for the application
   - Enables gzip compression
   - Configures proper caching headers
   - Sets up proper routing for React SPA

4. **Starts services:**
   - Ensures Nginx is running and enabled on boot

## Accessing the Website

After successful deployment, access your website at:

- http://15.207.112.73
- http://13.203.216.177

## Troubleshooting

### Connection Issues

If you can't connect to EC2 instances:

```bash
# Test SSH manually
ssh -i ansiblekey.pem ubuntu@15.207.112.73
```

### Check Nginx Status

```bash
ansible webservers -m shell -a "systemctl status nginx"
```

### View Application Logs

```bash
ansible webservers -m shell -a "tail -n 50 /var/log/nginx/gokboru_error.log"
```

### Redeploy After Changes

After making changes to your React app:

```bash
cd ansible
ansible-playbook deploy.yml
```

## Configuration Files

- **inventory.yml**: Defines EC2 hosts and connection parameters
- **ansible.cfg**: Ansible configuration settings
- **deploy.yml**: Main deployment playbook
- **roles/webserver/tasks/main.yml**: All deployment tasks
- **roles/webserver/templates/nginx-site.conf.j2**: Nginx configuration template

## Security Notes

1. Keep `ansiblekey.pem` secure and never commit it to version control
2. Consider setting up HTTPS with Let's Encrypt for production
3. Configure security groups in AWS to allow only necessary ports (80, 443, 22)
4. Update the EC2 instances regularly: `ansible webservers -m apt -a "upgrade=dist update_cache=yes" -b`

## Useful Commands

```bash
# List all hosts
ansible all --list-hosts

# Ping all servers
ansible all -m ping

# Check disk space
ansible webservers -m shell -a "df -h"

# Restart Nginx on all servers
ansible webservers -m service -a "name=nginx state=restarted" -b

# Update application only (skip dependency installation)
ansible-playbook deploy.yml --tags "deploy"
```

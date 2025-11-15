# 🚀 Complete Deployment Guide for GokBoru

## ✅ Ansible Installation Complete!

Ansible version 2.19.4 is now installed on your WSL Ubuntu system.

## 📋 Pre-Deployment Checklist

### 1. ⚠️ IMPORTANT: Place Your SSH Key

**You need to copy your `ansiblekey.pem` file to the ansible directory:**

```bash
# From Windows, copy your key to WSL:
# Option 1: If key is on Windows
cp /mnt/c/path/to/your/ansiblekey.pem ~/GokBoru/ansible/

# Option 2: If you need to download from AWS
# Go to AWS Console > EC2 > Key Pairs and download ansiblekey.pem
# Then place it in: ~/GokBoru/ansible/

# Set proper permissions (REQUIRED):
cd ~/GokBoru/ansible
chmod 400 ansiblekey.pem
```

### 2. ✅ Verify EC2 Instances

Make sure your EC2 instances:

- Are running (not stopped)
- Have Ubuntu OS installed
- Security Group allows:
  - SSH (port 22) from your IP
  - HTTP (port 80) from anywhere (0.0.0.0/0)

**Your configured servers:**

- Server 1: `15.207.112.73`
- Server 2: `13.203.216.177`

### 3. 🧪 Test Connection

Before deployment, test SSH connectivity:

```bash
cd ~/GokBoru/ansible

# Test connection with Ansible
ansible-playbook test-connection.yml

# Or test SSH manually
ssh -i ansiblekey.pem ubuntu@15.207.112.73
ssh -i ansiblekey.pem ubuntu@13.203.216.177
```

## 🎯 Deployment Commands

### Full Deployment (Both Servers)

```bash
cd ~/GokBoru/ansible
ansible-playbook deploy.yml
```

### Deploy to Single Server

```bash
# Deploy to server 1 only
ansible-playbook deploy.yml --limit ec2-server-1

# Deploy to server 2 only
ansible-playbook deploy.yml --limit ec2-server-2
```

### Verbose Mode (for troubleshooting)

```bash
ansible-playbook deploy.yml -vvv
```

## 📦 What Gets Deployed

The Ansible playbook will:

1. ✅ Update system packages
2. ✅ Install Nginx web server
3. ✅ Install Node.js 18.x and npm
4. ✅ Create `/var/www/gokboru` directory
5. ✅ Copy your React application files
6. ✅ Install npm dependencies
7. ✅ Build production bundle (`npm run build`)
8. ✅ Configure Nginx to serve the app
9. ✅ Start and enable Nginx service

## 🌐 Access Your Website

After successful deployment:

- **Server 1:** http://15.207.112.73
- **Server 2:** http://13.203.216.177

## 🔍 Verification Commands

### Check if Nginx is running

```bash
ansible webservers -m shell -a "systemctl status nginx"
```

### Check website files

```bash
ansible webservers -m shell -a "ls -la /var/www/gokboru/dist"
```

### View Nginx logs

```bash
# Error logs
ansible webservers -m shell -a "tail -n 20 /var/log/nginx/gokboru_error.log"

# Access logs
ansible webservers -m shell -a "tail -n 20 /var/log/nginx/gokboru_access.log"
```

### Test website response

```bash
curl http://15.207.112.73
curl http://13.203.216.177
```

## 🛠️ Common Issues & Solutions

### Issue 1: "Permission denied (publickey)"

**Solution:**

```bash
# Check key permissions
ls -l ~/GokBoru/ansible/ansiblekey.pem
# Should show: -r-------- (400)

# Fix permissions if needed
chmod 400 ~/GokBoru/ansible/ansiblekey.pem
```

### Issue 2: "Connection timeout"

**Solution:**

- Check EC2 instance is running in AWS Console
- Verify Security Group allows SSH from your IP
- Check if IP addresses are correct in `inventory.yml`

### Issue 3: "npm build failed"

**Solution:**

```bash
# SSH into server and debug
ssh -i ansiblekey.pem ubuntu@15.207.112.73
cd /var/www/gokboru
npm run build
# Check error messages
```

### Issue 4: Website not loading

**Solution:**

```bash
# Check Nginx status
ansible webservers -m shell -a "systemctl status nginx"

# Check Nginx configuration
ansible webservers -m shell -a "nginx -t"

# Restart Nginx
ansible webservers -m shell -a "systemctl restart nginx" -b
```

## 🔄 Redeploy After Code Changes

When you make changes to your React app:

```bash
cd ~/GokBoru/ansible
ansible-playbook deploy.yml
```

This will:

1. Sync new code to servers
2. Reinstall dependencies if package.json changed
3. Rebuild the application
4. Restart Nginx if needed

## 📊 Deployment Timeline

Typical deployment takes **3-5 minutes per server**:

- System updates: ~1 min
- Node.js installation: ~1 min
- File sync: ~30 sec
- npm install: ~1-2 min
- npm build: ~30 sec
- Nginx config: ~10 sec

## 🎓 Next Steps

### 1. Set up SSL/HTTPS (Recommended)

```bash
# Install Certbot on servers
ansible webservers -m apt -a "name=certbot,python3-certbot-nginx state=present" -b

# Get SSL certificate (run on each server individually)
ssh -i ansiblekey.pem ubuntu@15.207.112.73
sudo certbot --nginx -d yourdomain.com
```

### 2. Set up Custom Domain

- Point your domain DNS to EC2 IPs
- Update `nginx-site.conf.j2` with your domain name
- Redeploy

### 3. Set up Monitoring

Consider adding:

- AWS CloudWatch monitoring
- Uptime monitoring (UptimeRobot, Pingdom)
- Error tracking (Sentry)

### 4. Set up CI/CD

Create GitHub Actions workflow to auto-deploy on push:

- Build and test on GitHub
- Deploy via Ansible
- Notify on success/failure

## 📞 Need Help?

If you encounter issues:

1. Run in verbose mode: `ansible-playbook deploy.yml -vvv`
2. Check Ansible logs
3. SSH into server and check manually
4. Verify AWS Security Groups and EC2 instance status

## 🎉 Success!

Once deployed, your GokBoru website will be:

- ✅ Accessible via HTTP
- ✅ Optimized for production (minified, compressed)
- ✅ Served by Nginx with caching
- ✅ Running on both EC2 instances

Remember to place your `ansiblekey.pem` in the ansible directory before running any commands!

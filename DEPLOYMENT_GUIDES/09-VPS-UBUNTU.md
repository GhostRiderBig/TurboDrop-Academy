# Deploying to Ubuntu VPS

This guide covers manual deployment to Ubuntu VPS (DigitalOcean, Linode, Vultr, AWS EC2, etc.).

## Prerequisites

- Ubuntu VPS (20.04, 22.04, or 24.04)
- Root or sudo access
- SSH access
- Domain name (optional)

---

## Quick Start (Automated)

Use the included deployment script:

```bash
# Upload files to VPS
scp -r /path/to/landing-page root@your-vps-ip:/root/

# SSH into VPS
ssh root@your-vps-ip

# Run deployment script
cd /root/landing-page
chmod +x deploy.sh
./deploy.sh
```

The script handles everything automatically!

---

## Manual Deployment with Nginx

### Step 1: Update System

```bash
sudo apt update
sudo apt upgrade -y
```

### Step 2: Install Nginx

```bash
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
```

### Step 3: Upload Files

**From your local machine:**

```bash
# Upload via SCP
scp -r /path/to/landing-page root@your-vps-ip:/tmp/

# Or use rsync (faster for updates)
rsync -avz --delete /path/to/landing-page/ root@your-vps-ip:/tmp/landing-page/
```

**Or use SFTP client like FileZilla:**
- Host: `sftp://your-vps-ip`
- Username: `root`
- Password: your password
- Upload to `/tmp/`

### Step 4: Move Files to Web Directory

```bash
# SSH into VPS
ssh root@your-vps-ip

# Create site directory
sudo mkdir -p /var/www/example.com

# Move files
sudo cp -r /tmp/landing-page/* /var/www/example.com/

# Set ownership
sudo chown -R www-data:www-data /var/www/example.com

# Set permissions
sudo chmod -R 755 /var/www/example.com
```

### Step 5: Configure Nginx

Create Nginx configuration:

```bash
sudo nano /etc/nginx/sites-available/example.com
```

Paste this configuration (replace `example.com` with your domain):

```nginx
server {
    listen 80;
    listen [::]:80;

    server_name example.com www.example.com;
    root /var/www/example.com;
    index index.html;

    access_log /var/log/nginx/example.com-access.log;
    error_log /var/log/nginx/example.com-error.log;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/json application/xml+rss image/svg+xml;

    # Main location
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static files
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|webp)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
    }
}
```

Save and exit (Ctrl+X, Y, Enter).

### Step 6: Enable Site

```bash
# Create symbolic link
sudo ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

### Step 7: Configure Firewall

```bash
# Allow HTTP and HTTPS
sudo ufw allow 'Nginx Full'

# Enable firewall (if not already)
sudo ufw enable
```

### Step 8: Point Domain to VPS

Update DNS records at your domain registrar:

```
Type    Name    Value
A       @       YOUR.VPS.IP.ADDRESS
A       www     YOUR.VPS.IP.ADDRESS
```

Wait for DNS propagation (5 mins - 48 hours).

### Step 9: Setup SSL (HTTPS)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get SSL certificate
sudo certbot --nginx -d example.com -d www.example.com

# Follow prompts:
# - Enter email
# - Agree to terms
# - Choose redirect (recommended: Yes)

# Test auto-renewal
sudo certbot renew --dry-run
```

Your site is now live with HTTPS! 🎉

---

## Manual Deployment with Apache

### Install Apache

```bash
sudo apt update
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo systemctl start apache2
```

### Configure Apache

```bash
# Upload and move files (same as Nginx steps 3-4)
sudo mkdir -p /var/www/example.com
sudo cp -r /tmp/landing-page/* /var/www/example.com/
sudo chown -R www-data:www-data /var/www/example.com
sudo chmod -R 755 /var/www/example.com
```

Create virtual host:

```bash
sudo nano /etc/apache2/sites-available/example.com.conf
```

Paste:

```apache
<VirtualHost *:80>
    ServerName example.com
    ServerAlias www.example.com
    DocumentRoot /var/www/example.com

    <Directory /var/www/example.com>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/example.com-error.log
    CustomLog ${APACHE_LOG_DIR}/example.com-access.log combined
</VirtualHost>
```

Enable site:

```bash
sudo a2enmod rewrite
sudo a2ensite example.com.conf
sudo systemctl reload apache2
```

### SSL for Apache

```bash
sudo apt install certbot python3-certbot-apache -y
sudo certbot --apache -d example.com -d www.example.com
```

---

## Subfolder Deployment

### For Nginx

Add location block to existing config:

```nginx
location /landing {
    alias /var/www/landing;
    index index.html;
    try_files $uri $uri/ /landing/index.html;
}
```

### For Apache

Upload files to `/var/www/html/landing/` and Apache handles it automatically with the included `.htaccess` file.

---

## Updating Your Site

```bash
# From local machine:
rsync -avz --delete /path/to/landing-page/ root@your-vps-ip:/var/www/example.com/

# Or update specific files:
scp /path/to/index.html root@your-vps-ip:/var/www/example.com/

# No need to restart Nginx/Apache for static files!
```

---

## Troubleshooting

### Check Nginx Status

```bash
sudo systemctl status nginx
sudo nginx -t
sudo tail -f /var/log/nginx/error.log
```

### Check Apache Status

```bash
sudo systemctl status apache2
sudo apache2ctl configtest
sudo tail -f /var/log/apache2/error.log
```

### Fix Permissions

```bash
sudo chown -R www-data:www-data /var/www/example.com
sudo chmod -R 755 /var/www/example.com
sudo chmod 644 /var/www/example.com/*.html
```

### Restart Services

```bash
sudo systemctl restart nginx
# or
sudo systemctl restart apache2
```

---

## Security Best Practices

### 1. Update Regularly

```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Use Firewall

```bash
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'  # or 'Apache Full'
sudo ufw enable
```

### 3. Disable Root Login

```bash
# Create sudo user first
sudo adduser youruser
sudo usermod -aG sudo youruser

# Then disable root SSH
sudo nano /etc/ssh/sshd_config
# Change: PermitRootLogin no
sudo systemctl restart ssh
```

### 4. Install Fail2Ban

```bash
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
```

### 5. Use SSH Keys

```bash
# On local machine:
ssh-keygen -t rsa -b 4096

# Copy to VPS:
ssh-copy-id root@your-vps-ip
```

---

## Performance Optimization

### Enable Caching

Already configured in nginx.conf.

### Enable HTTP/2

In Nginx config, change:
```nginx
listen 443 ssl http2;
listen [::]:443 ssl http2;
```

### Install Redis (optional)

```bash
sudo apt install redis-server -y
```

---

## Monitoring

### Check Resource Usage

```bash
# CPU and memory
htop

# Disk usage
df -h

# Network usage
iftop
```

### Setup Monitoring (optional)

- **Netdata**: Real-time monitoring
  ```bash
  bash <(curl -Ss https://my-netdata.io/kickstart.sh)
  ```

- **Uptime Robot**: External monitoring (free)
  - [uptimerobot.com](https://uptimerobot.com)

---

## Backup

### Manual Backup

```bash
# Backup website
tar -czf website-backup-$(date +%Y%m%d).tar.gz /var/www/example.com

# Download to local
scp root@your-vps-ip:/root/website-backup-*.tar.gz ./
```

### Automated Backup

Create cron job:

```bash
crontab -e
```

Add:

```bash
0 2 * * * tar -czf /backups/website-$(date +\%Y\%m\%d).tar.gz /var/www/example.com
```

---

## Cost-Effective VPS Providers

- **DigitalOcean** - $4-6/month - [digitalocean.com](https://www.digitalocean.com)
- **Linode** - $5/month - [linode.com](https://www.linode.com)
- **Vultr** - $3.50/month - [vultr.com](https://www.vultr.com)
- **Hetzner** - €3.79/month - [hetzner.com](https://www.hetzner.com)

---

[← Back to Main README](../README.md)

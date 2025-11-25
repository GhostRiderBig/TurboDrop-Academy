# Landing Page Deployment Guide

Welcome! This guide will help you deploy your landing page to various hosting platforms and servers.

## Table of Contents

- [Quick Start](#quick-start)
- [Deployment Options](#deployment-options)
  - [Option 1: Cloud Platforms (Easiest)](#option-1-cloud-platforms-easiest)
  - [Option 2: Shared Hosting (cPanel/FTP)](#option-2-shared-hosting-cpanelftp)
  - [Option 3: VPS/Cloud Servers](#option-3-vpscloud-servers)
  - [Option 4: Docker](#option-4-docker)
- [Detailed Platform Guides](#detailed-platform-guides)
- [SSL/HTTPS Setup](#sslhttps-setup)
- [Custom Domain Configuration](#custom-domain-configuration)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

Your landing page is a **static website** consisting of:
- `index.html` - Main page
- `style.css` - Styles
- `script.js` - JavaScript functionality
- `images/` - Images folder
- `_privacy.html` - Privacy policy
- `_terms.html` - Terms of service

**Total size:** ~600KB (very lightweight!)

### Fastest Deployment (3 methods)

1. **Drag & Drop** → Use Netlify Drop (no account needed)
2. **One Command** → Run `./deploy.sh` on VPS (Ubuntu/Debian)
3. **Docker** → Run `docker-compose up -d`

---

## Deployment Options

### Option 1: Cloud Platforms (Easiest)

Perfect for: Quick deployment, free hosting, automatic SSL

#### Netlify (Recommended for beginners)

**Method 1: Drag & Drop (No account required)**
1. Go to [https://app.netlify.com/drop](https://app.netlify.com/drop)
2. Drag the entire folder (or zip file) onto the page
3. Get instant live URL (e.g., `random-name-123456.netlify.app`)
4. Optional: Connect custom domain in settings

**Method 2: CLI Deployment**
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
netlify deploy --prod
```

📖 See [DEPLOYMENT_GUIDES/01-NETLIFY.md](DEPLOYMENT_GUIDES/01-NETLIFY.md) for detailed instructions

#### Vercel

```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel --prod
```

📖 See [DEPLOYMENT_GUIDES/02-VERCEL.md](DEPLOYMENT_GUIDES/02-VERCEL.md)

#### Cloudflare Pages

```bash
# Install Wrangler CLI
npm install -g wrangler

# Login and deploy
wrangler login
wrangler pages deploy . --project-name=my-landing
```

📖 See [DEPLOYMENT_GUIDES/03-CLOUDFLARE.md](DEPLOYMENT_GUIDES/03-CLOUDFLARE.md)

#### GitHub Pages

```bash
# Initialize git repository
git init
git add .
git commit -m "Initial commit"

# Create GitHub repo and push
git remote add origin https://github.com/yourusername/your-repo.git
git branch -M main
git push -u origin main

# Enable GitHub Pages in repository settings
# Settings → Pages → Source: main branch
```

📖 See [DEPLOYMENT_GUIDES/04-GITHUB-PAGES.md](DEPLOYMENT_GUIDES/04-GITHUB-PAGES.md)

---

### Option 2: Shared Hosting (cPanel/FTP)

Perfect for: Existing hosting accounts, simple setups

#### cPanel Hosting

**Deploy to Root Domain (e.g., `example.com`)**

1. Log into cPanel
2. Open **File Manager**
3. Navigate to `public_html/`
4. Upload all files (or extract zip archive)
5. Your site is live at `https://example.com`

**Deploy to Subfolder (e.g., `example.com/landing`)**

1. Log into cPanel
2. Open **File Manager**
3. Navigate to `public_html/`
4. Create new folder: `landing/`
5. Upload all files into `public_html/landing/`
6. Your site is live at `https://example.com/landing`

**Important:** If using subfolder, update links in HTML:
- Change `href="style.css"` to `href="./style.css"`
- Change `src="images/photo.jpg"` to `src="./images/photo.jpg"`

📖 See [DEPLOYMENT_GUIDES/05-CPANEL.md](DEPLOYMENT_GUIDES/05-CPANEL.md)

#### FTP Hosting

```bash
# Using FileZilla or any FTP client:
# 1. Connect to your FTP server
# 2. Navigate to public_html/ (or www/ or htdocs/)
# 3. Upload all files
# 4. Done!
```

---

### Option 3: VPS/Cloud Servers

Perfect for: Full control, custom configurations

#### Automated Deployment Script

We provide an interactive deployment script that handles everything:

```bash
# Make script executable
chmod +x deploy.sh

# Run deployment wizard
./deploy.sh
```

The script will:
- ✅ Detect your OS (Ubuntu/Debian/CentOS/macOS)
- ✅ Offer Apache or Nginx installation
- ✅ Configure web server
- ✅ Set up SSL with Let's Encrypt
- ✅ Configure custom domain or subfolder
- ✅ Start the web server

**Supported Operating Systems:**
- Ubuntu 20.04, 22.04, 24.04
- Debian 10, 11, 12
- CentOS 7, 8, 9
- macOS (for local testing)

#### Manual Deployment

##### DigitalOcean App Platform

```bash
# Using doctl CLI
doctl apps create --spec .do/app.yaml

# Or use web interface:
# Deploy → Static Site → Upload folder
```

📖 See [DEPLOYMENT_GUIDES/06-DIGITALOCEAN.md](DEPLOYMENT_GUIDES/06-DIGITALOCEAN.md)

##### AWS S3 Static Website

```bash
# Create S3 bucket
aws s3 mb s3://my-landing-page

# Upload files
aws s3 sync . s3://my-landing-page --exclude "*.sh" --exclude "*.md"

# Enable static website hosting
aws s3 website s3://my-landing-page --index-document index.html
```

📖 See [DEPLOYMENT_GUIDES/07-AWS-S3.md](DEPLOYMENT_GUIDES/07-AWS-S3.md)

##### Azure Static Web Apps

```bash
# Install Azure CLI
az login

# Create static web app
az staticwebapp create \
  --name my-landing \
  --resource-group my-resource-group \
  --source . \
  --location "East US 2"
```

📖 See [DEPLOYMENT_GUIDES/08-AZURE.md](DEPLOYMENT_GUIDES/08-AZURE.md)

##### Ubuntu/Debian VPS with Nginx

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Nginx
sudo apt install nginx -y

# Copy files
sudo cp -r * /var/www/html/

# Configure Nginx (see nginx.conf)
sudo cp nginx.conf /etc/nginx/sites-available/landing
sudo ln -s /etc/nginx/sites-available/landing /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

📖 See [DEPLOYMENT_GUIDES/09-VPS-UBUNTU.md](DEPLOYMENT_GUIDES/09-VPS-UBUNTU.md)

---

### Option 4: Docker

Perfect for: Containerized deployments, portability

```bash
# Start with docker-compose (easiest)
docker-compose up -d

# Your site will be available at http://localhost:8080
```

**Custom port:**
```bash
PORT=3000 docker-compose up -d
```

**With custom domain:**
Edit `docker-compose.yml` and update environment variables

📖 See [DEPLOYMENT_GUIDES/10-DOCKER.md](DEPLOYMENT_GUIDES/10-DOCKER.md)

---

## Detailed Platform Guides

Each platform has a dedicated guide with step-by-step instructions:

1. [Netlify](DEPLOYMENT_GUIDES/01-NETLIFY.md) - Drag & drop deployment
2. [Vercel](DEPLOYMENT_GUIDES/02-VERCEL.md) - CLI and Git deployment
3. [Cloudflare Pages](DEPLOYMENT_GUIDES/03-CLOUDFLARE.md) - Edge deployment
4. [GitHub Pages](DEPLOYMENT_GUIDES/04-GITHUB-PAGES.md) - Free hosting with Git
5. [cPanel](DEPLOYMENT_GUIDES/05-CPANEL.md) - Shared hosting deployment
6. [DigitalOcean](DEPLOYMENT_GUIDES/06-DIGITALOCEAN.md) - App Platform & Droplets
7. [AWS S3](DEPLOYMENT_GUIDES/07-AWS-S3.md) - S3 static website hosting
8. [Azure](DEPLOYMENT_GUIDES/08-AZURE.md) - Azure Static Web Apps
9. [VPS Ubuntu](DEPLOYMENT_GUIDES/09-VPS-UBUNTU.md) - Manual VPS setup
10. [Docker](DEPLOYMENT_GUIDES/10-DOCKER.md) - Containerized deployment

---

## SSL/HTTPS Setup

### Cloud Platforms
All cloud platforms (Netlify, Vercel, Cloudflare Pages, GitHub Pages) provide **automatic SSL certificates** for free. No configuration needed!

### Let's Encrypt (Free SSL for VPS)

```bash
# Ubuntu/Debian
sudo apt install certbot python3-certbot-nginx -y

# For Nginx
sudo certbot --nginx -d yourdomain.com

# For Apache
sudo certbot --apache -d yourdomain.com

# Auto-renewal is configured automatically
```

### cPanel
Most cPanel hosting includes free SSL (Let's Encrypt):
1. Go to cPanel → SSL/TLS Status
2. Click "Run AutoSSL" or enable Let's Encrypt
3. SSL will be activated automatically

---

## Custom Domain Configuration

### Cloud Platforms (Netlify/Vercel/Cloudflare)

1. Add custom domain in platform dashboard
2. Update DNS records:

```
Type    Name    Value
A       @       [Platform IP]
CNAME   www     [Platform domain]
```

Platform-specific DNS values:
- **Netlify**: A record to `75.2.60.5`, CNAME to `[your-site].netlify.app`
- **Vercel**: CNAME to `cname.vercel-dns.com`
- **Cloudflare Pages**: Follow dashboard instructions (auto-configured if using Cloudflare DNS)

### VPS/Self-hosted

1. Point domain A record to your server IP:

```
Type    Name    Value
A       @       YOUR.SERVER.IP.ADDRESS
A       www     YOUR.SERVER.IP.ADDRESS
```

2. Configure virtual host (see platform guides)
3. Set up SSL with Let's Encrypt (see above)

### Subfolder on Existing Domain

If you want `example.com/landing` instead of separate domain:

**Nginx:**
```nginx
location /landing {
    alias /var/www/landing;
    index index.html;
}
```

**Apache (.htaccess already included):**
Just upload files to subdirectory. The included `.htaccess` handles routing.

---

## Troubleshooting

### Page shows 404 errors
- **Check file permissions:** `chmod 644 *.html *.css *.js` and `chmod 755 images/`
- **Verify paths:** All links should use relative paths (`./` or `../`)

### CSS/JS not loading
- **Check file paths** in `index.html` - should be relative (`./style.css` not `/style.css`)
- **Clear browser cache:** Ctrl+Shift+R (Windows/Linux) or Cmd+Shift+R (Mac)
- **Check MIME types** in web server config

### Images not displaying
- **File names:** Ensure exact case match (Linux is case-sensitive)
- **Permissions:** `chmod 755 images/` and `chmod 644 images/*`
- **Paths:** Use relative paths (`./images/photo.jpg`)

### SSL Certificate errors
```bash
# Renew Let's Encrypt certificate
sudo certbot renew

# Test renewal
sudo certbot renew --dry-run
```

### Port already in use (Docker)
```bash
# Check what's using port 80
sudo lsof -i :80

# Use different port
PORT=8080 docker-compose up -d
```

### Nginx/Apache won't start
```bash
# Check syntax
sudo nginx -t
sudo apache2ctl configtest

# View error logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/apache2/error.log
```

---

## Need Help?

- **Cloud Platforms:** Check platform status pages and documentation
- **Server Issues:** Review web server logs (`/var/log/nginx/` or `/var/log/apache2/`)
- **DNS Issues:** Use tools like [DNS Checker](https://dnschecker.org) to verify propagation
- **SSL Issues:** Test with [SSL Labs](https://www.ssllabs.com/ssltest/)

---

## File Structure Reference

```
landing-page/
├── index.html              # Main page
├── style.css               # Styles
├── script.js               # JavaScript
├── _privacy.html           # Privacy policy
├── _terms.html             # Terms of service
├── images/                 # Images folder
│   └── *.webp             # Image files
├── README.md              # This file
├── deploy.sh              # Automated deployment script
├── docker-compose.yml     # Docker configuration
├── Dockerfile             # Docker image
├── .htaccess              # Apache configuration
├── nginx.conf             # Nginx configuration
├── netlify.toml           # Netlify configuration
├── vercel.json            # Vercel configuration
└── DEPLOYMENT_GUIDES/     # Detailed platform guides
    ├── 01-NETLIFY.md
    ├── 02-VERCEL.md
    ├── 03-CLOUDFLARE.md
    ├── 04-GITHUB-PAGES.md
    ├── 05-CPANEL.md
    ├── 06-DIGITALOCEAN.md
    ├── 07-AWS-S3.md
    ├── 08-AZURE.md
    ├── 09-VPS-UBUNTU.md
    └── 10-DOCKER.md
```

---

## License

This landing page and deployment tools are provided as-is. Feel free to modify and deploy as needed.

**Generated with Vsesvit.AI** - [https://vsesvit.ai](https://vsesvit.ai)

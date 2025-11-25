# Deploying to DigitalOcean

DigitalOcean offers multiple ways to deploy your landing page: App Platform (easiest), Droplets (VPS), or Spaces (S3-like storage).

## Option 1: App Platform (Recommended - Easiest)

Free for static sites! No server management needed.

### Via Web Interface

1. **Sign up/Login**
   - Go to [digitalocean.com](https://www.digitalocean.com)
   - Create account or login

2. **Create App**
   - Click "Create" → "App Platform"
   - Choose "Static Site"

3. **Upload Files**
   - Option A: Connect GitHub/GitLab repo
   - Option B: Upload files directly

4. **Configure**
   - Name: `my-landing-page`
   - Region: Choose closest to your users
   - Build command: Leave blank
   - Output directory: Leave blank

5. **Deploy**
   - Click "Next" → "Review" → "Create Resources"
   - Wait 1-2 minutes

6. **Get URL**
   ```
   https://my-landing-page-xxxxx.ondigitalocean.app
   ```

### Via doctl CLI

```bash
# Install doctl
brew install doctl  # macOS
# or download from digitalocean.com/docs/apis-clis/doctl/

# Login
doctl auth init

# Create app spec file
cat > app.yaml <<EOF
name: my-landing-page
static_sites:
- name: web
  source_dir: /
  output_dir: /
  routes:
  - path: /
EOF

# Deploy
doctl apps create --spec app.yaml

# Or update existing
doctl apps update <app-id> --spec app.yaml
```

### Custom Domain

1. In App settings → "Domains"
2. Add domain: `example.com`
3. Update DNS records:
   ```
   Type     Name    Value
   CNAME    @       <provided-by-digitalocean>
   CNAME    www     <provided-by-digitalocean>
   ```

### Pricing (App Platform)
- **Static Sites: FREE** (3 static sites)
- Auto-SSL included
- Global CDN included

---

## Option 2: Droplet (VPS)

For more control, use a Droplet (virtual server).

### Create Droplet

1. **Create Droplet**
   - Click "Create" → "Droplets"
   - Choose Ubuntu 24.04
   - Plan: Basic ($4-6/month)
   - Add SSH key (recommended)
   - Click "Create Droplet"

2. **Wait for Droplet to Start**
   - Takes 1-2 minutes
   - Note the IP address

3. **SSH into Droplet**
   ```bash
   ssh root@your-droplet-ip
   ```

4. **Deploy**
   - Follow [VPS Ubuntu Guide](09-VPS-UBUNTU.md)
   - Or use the automated deployment script:
     ```bash
     # Upload files
     scp -r /path/to/landing-page root@your-droplet-ip:/root/

     # Run deployment
     ssh root@your-droplet-ip
     cd /root/landing-page
     chmod +x deploy.sh
     ./deploy.sh
     ```

### Add Domain to Droplet

1. In DigitalOcean dashboard → "Networking" → "Domains"
2. Add domain: `example.com`
3. Create A records:
   ```
   Type    Hostname    Value
   A       @           your-droplet-ip
   A       www         your-droplet-ip
   ```

### Pricing (Droplets)
- **Basic:** $4/month (512MB RAM)
- **Standard:** $6/month (1GB RAM) ← Recommended
- Includes 1TB transfer

---

## Option 3: Spaces (S3-Compatible Storage)

For CDN-backed static hosting.

### Via Web Interface

1. **Create Space**
   - Click "Create" → "Spaces"
   - Choose region
   - Name: `my-landing`
   - Enable CDN
   - Make public

2. **Upload Files**
   - Drag and drop files to Space
   - Or use web interface to upload

3. **Get URL**
   ```
   https://my-landing.nyc3.digitaloceanspaces.com
   # or with CDN:
   https://my-landing.nyc3.cdn.digitaloceanspaces.com
   ```

### Via s3cmd

```bash
# Install s3cmd
pip install s3cmd

# Configure
s3cmd --configure
# Enter your DigitalOcean Spaces keys
# Endpoint: nyc3.digitaloceanspaces.com

# Upload
s3cmd sync /path/to/landing-page/ s3://my-landing/ --acl-public

# Enable website hosting
s3cmd ws-create --ws-index=index.html --ws-error=index.html s3://my-landing
```

### Custom Domain for Spaces

1. Create CNAME record:
   ```
   Type     Name    Value
   CNAME    cdn     my-landing.nyc3.cdn.digitaloceanspaces.com
   ```
2. Add SSL certificate in Spaces settings

### Pricing (Spaces)
- **$5/month** for 250GB storage
- 1TB outbound transfer included
- CDN included

---

## Comparison

| Feature | App Platform | Droplet | Spaces |
|---------|-------------|---------|---------|
| Price | **FREE** | $4-6/mo | $5/mo |
| Difficulty | Easiest | Medium | Easy |
| Control | Limited | Full | Limited |
| SSL | Auto | Manual | Manual |
| Best for | Quick deploy | Full control | CDN needs |

**Recommendation:** Use **App Platform** for easiest deployment.

---

## Monitoring

### Enable Monitoring (Droplets)

```bash
# Install agent
curl -sSL https://repos.insights.digitalocean.com/install.sh | sudo bash
```

View metrics in DigitalOcean dashboard.

---

## Useful Commands

```bash
# List apps
doctl apps list

# Get app details
doctl apps get <app-id>

# View logs
doctl apps logs <app-id>

# List droplets
doctl compute droplet list

# List spaces
doctl spaces list
```

---

## Additional Features

### Load Balancer (Optional)
- Add load balancer for high traffic
- $10/month

### Managed Database (Optional)
- If you need a database
- From $15/month

### Backups
- Automatic droplet backups: +20% of droplet cost
- Spaces backups: automatic, included

---

## Resources

- [DigitalOcean Documentation](https://docs.digitalocean.com/)
- [App Platform Docs](https://docs.digitalocean.com/products/app-platform/)
- [Droplet Docs](https://docs.digitalocean.com/products/droplets/)
- [Spaces Docs](https://docs.digitalocean.com/products/spaces/)

---

[← Back to Main README](../README.md)

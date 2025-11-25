# Deploying to Netlify

[Netlify](https://www.netlify.com/) is one of the easiest platforms for deploying static websites. It offers free hosting with SSL, custom domains, and global CDN.

## Prerequisites

- None for drag & drop method
- Node.js and npm for CLI method
- Git and GitHub account for Git-based deployment

## Method 1: Drag & Drop (Easiest - No Account Required)

This is the fastest way to get your site online!

### Steps:

1. **Go to Netlify Drop**
   - Visit: [https://app.netlify.com/drop](https://app.netlify.com/drop)

2. **Drag Your Folder**
   - Drag the entire landing page folder (or zip file) onto the page
   - Netlify will upload and deploy automatically

3. **Get Your URL**
   - After upload completes, you'll get a live URL like:
     ```
     https://random-name-123456.netlify.app
     ```
   - Your site is now live!

4. **Optional: Claim Your Site**
   - Click "Claim site" to save it to your account
   - This allows you to update it later and add a custom domain

### Updating Your Site:
- Simply drag the updated folder again to the same URL
- Or claim the site and use the dashboard

---

## Method 2: Netlify CLI

Perfect for repeated deployments and automation.

### Steps:

1. **Install Netlify CLI**
   ```bash
   npm install -g netlify-cli
   ```

2. **Navigate to Your Folder**
   ```bash
   cd /path/to/landing-page
   ```

3. **Login to Netlify**
   ```bash
   netlify login
   ```
   - This opens a browser to authorize the CLI

4. **Deploy**

   **For first deployment:**
   ```bash
   netlify deploy
   ```
   - Choose "Create & configure a new site"
   - Select your team
   - Enter a site name (or leave blank for random)
   - Specify publish directory: `.` (current directory)

   **For production deployment:**
   ```bash
   netlify deploy --prod
   ```

5. **Get Your URL**
   - Netlify will show your site URL:
     ```
     https://your-site-name.netlify.app
     ```

### Updating Your Site:
```bash
# Make changes to your files, then:
netlify deploy --prod
```

---

## Method 3: Git-Based Deployment (Continuous Deployment)

Automatically deploy when you push to GitHub!

### Steps:

1. **Initialize Git Repository**
   ```bash
   cd /path/to/landing-page
   git init
   git add .
   git commit -m "Initial commit"
   ```

2. **Create GitHub Repository**
   - Go to [GitHub](https://github.com)
   - Click "New repository"
   - Name it (e.g., "my-landing-page")
   - **Don't** initialize with README (your repo already has files)

3. **Push to GitHub**
   ```bash
   git remote add origin https://github.com/yourusername/your-repo.git
   git branch -M main
   git push -u origin main
   ```

4. **Connect to Netlify**
   - Go to [Netlify Dashboard](https://app.netlify.com)
   - Click "Add new site" → "Import an existing project"
   - Choose "GitHub"
   - Authorize Netlify to access your repositories
   - Select your repository

5. **Configure Build Settings**
   - Build command: Leave blank (no build needed)
   - Publish directory: `.` or leave blank
   - Click "Deploy site"

6. **Wait for Deployment**
   - Netlify will deploy your site (usually takes 30-60 seconds)
   - You'll get a URL like: `https://random-name.netlify.app`

### Updating Your Site:
```bash
# Make changes to your files, then:
git add .
git commit -m "Update content"
git push

# Netlify automatically redeploys!
```

---

## Adding a Custom Domain

### Steps:

1. **Go to Site Settings**
   - In Netlify dashboard, select your site
   - Go to "Domain settings"

2. **Add Custom Domain**
   - Click "Add custom domain"
   - Enter your domain (e.g., `example.com`)
   - Click "Verify"

3. **Update DNS Records**

   **Option A: Use Netlify DNS (Recommended)**
   - Click "Set up Netlify DNS"
   - Netlify will provide nameservers (usually in format: `dns1-4.p0X.nsone.net`)
   - Update your domain's nameservers at your domain registrar to the ones provided by Netlify
   - Example nameservers (yours may differ):
     ```
     dns1.p01.nsone.net
     dns2.p01.nsone.net
     dns3.p01.nsone.net
     dns4.p01.nsone.net
     ```
   - SSL certificate is automatically provisioned

   **Option B: Use External DNS**
   - Add these DNS records at your domain registrar:
     ```
     Type    Name    Value
     A       @       75.2.60.5
     CNAME   www     your-site.netlify.app
     ```
   - Wait for DNS propagation (5 minutes - 48 hours)

4. **Enable HTTPS**
   - Netlify automatically provisions SSL certificate
   - Usually takes 1-5 minutes
   - Once ready, enable "Force HTTPS" in domain settings

---

## Configuration File (netlify.toml)

The included `netlify.toml` file automatically configures:
- SPA routing (redirects to index.html)
- Security headers
- Cache headers for performance
- Custom redirects

You can customize it by editing the file.

---

## Environment Variables (If Needed)

If your site needs environment variables:

1. Go to "Site settings" → "Build & deploy" → "Environment"
2. Click "Edit variables"
3. Add your variables
4. Redeploy

---

## Troubleshooting

### Issue: Files not showing up
**Solution:**
- Check publish directory is set to `.` or blank
- Ensure all files are committed to git (for git deployments)

### Issue: 404 errors
**Solution:**
- The `netlify.toml` file handles SPA routing
- Make sure `netlify.toml` is in the root of your site

### Issue: Custom domain not working
**Solution:**
- Check DNS records with [DNS Checker](https://dnschecker.org)
- Wait up to 48 hours for DNS propagation
- Verify DNS records are correct

### Issue: SSL certificate pending
**Solution:**
- Wait 5-10 minutes for provisioning
- Ensure DNS is pointing to Netlify correctly
- Check domain is verified in Netlify dashboard

---

## Performance Tips

1. **Enable Asset Optimization** (in Site settings → Build & deploy → Post processing)
   - Bundle CSS
   - Minify CSS
   - Minify JS
   - Compress images

2. **Use Netlify Analytics** (optional paid feature)
   - See real-time visitor data
   - No cookie banners needed

3. **Prerendering** (if needed for SEO)
   - Enable in Site settings → Build & deploy → Prerendering

---

## Useful Commands

```bash
# Check deployment status
netlify status

# Open site in browser
netlify open:site

# View site logs
netlify logs

# Link existing site
netlify link

# Unlink site
netlify unlink

# View all sites
netlify sites:list
```

---

## Pricing

- **Free Tier:**
  - 100 GB bandwidth/month
  - Unlimited sites
  - SSL included
  - Custom domains

- **Pro Tier ($19/month):**
  - 400 GB bandwidth
  - Advanced features

For static landing pages, the **free tier is usually sufficient**.

---

## Additional Resources

- [Netlify Documentation](https://docs.netlify.com/)
- [Netlify Community](https://answers.netlify.com/)
- [Netlify Status](https://www.netlifystatus.com/)

---

**Need help?** Visit the main [README.md](../README.md) or check [troubleshooting section](#troubleshooting).

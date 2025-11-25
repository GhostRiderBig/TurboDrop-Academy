# Deploying to Vercel

[Vercel](https://vercel.com/) is a cloud platform optimized for frontend frameworks and static sites. It offers free hosting with SSL, custom domains, and edge network deployment.

## Prerequisites

- Node.js and npm (for CLI method)
- Git and GitHub/GitLab/Bitbucket account (for Git method)
- Vercel account (free to create)

## Method 1: Vercel CLI (Recommended)

### Steps:

1. **Install Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **Navigate to Your Folder**
   ```bash
   cd /path/to/landing-page
   ```

3. **Deploy**
   ```bash
   vercel
   ```

   First time deployment prompts:
   - **Set up and deploy?** → Yes
   - **Which scope?** → Select your account
   - **Link to existing project?** → No
   - **Project name** → landing-page (or your preferred name)
   - **In which directory?** → ./ (press Enter)
   - **Override settings?** → No

4. **Production Deployment**
   ```bash
   vercel --prod
   ```

5. **Get Your URL**
   ```
   https://your-project.vercel.app
   ```

### Updating Your Site:
```bash
# Make changes, then:
vercel --prod
```

---

## Method 2: Git-Based Deployment

### Steps:

1. **Push to Git Repository** (GitHub/GitLab/Bitbucket)
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/yourusername/your-repo.git
   git push -u origin main
   ```

2. **Import to Vercel**
   - Go to [Vercel Dashboard](https://vercel.com/dashboard)
   - Click "Add New..." → "Project"
   - Import your Git repository
   - Click "Deploy"

3. **Configure (if needed)**
   - Framework Preset: **Other**
   - Build Command: Leave blank
   - Output Directory: `.` or leave blank
   - Install Command: Leave blank

4. **Deploy**
   - Click "Deploy"
   - Wait 30-60 seconds

### Auto-Deployment:
Every `git push` automatically triggers a new deployment!

---

## Method 3: Drag & Drop (Vercel Dashboard)

1. Go to [Vercel Dashboard](https://vercel.com/dashboard)
2. Click "Add New..." → "Project"
3. Drag your folder to upload
4. Click "Deploy"

---

## Adding Custom Domain

1. **Go to Project Settings**
   - Select your project → "Settings" → "Domains"

2. **Add Domain**
   - Enter your domain (e.g., `example.com`)
   - Click "Add"

3. **Configure DNS**

   Add these records at your domain registrar:

   **For apex domain (example.com):**
   ```
   Type      Name    Value
   A         @       76.76.21.21
   ```

   **Note:** Some DNS providers support ALIAS or ANAME records for apex domains:
   ```
   Type      Name    Value
   ALIAS     @       cname.vercel-dns.com  (if supported)
   ```

   **For www subdomain:**
   ```
   Type     Name    Value
   CNAME    www     cname.vercel-dns.com
   ```

   **Important:** Standard CNAME records cannot be used for apex (@) domains on most DNS providers. Use A record or ALIAS/ANAME if your provider supports it.

4. **Wait for Verification**
   - Usually takes 5-10 minutes
   - SSL certificate is automatically provisioned

---

## Configuration (vercel.json)

The included `vercel.json` file configures:
- Static file serving
- SPA routing
- Security headers
- Cache headers

---

## Environment Variables

1. Go to "Project Settings" → "Environment Variables"
2. Add variables for Production/Preview/Development
3. Redeploy to apply changes

---

## Troubleshooting

### Issue: Build fails
**Solution:** Ensure build command is blank for static sites

### Issue: Custom domain not working
**Solution:** Check DNS with [DNS Checker](https://dnschecker.org)

### Issue: Files not updating
**Solution:** Clear Vercel cache or redeploy with `vercel --prod --force`

---

## Useful Commands

```bash
# Login
vercel login

# Deploy to production
vercel --prod

# List deployments
vercel ls

# View logs
vercel logs

# Remove deployment
vercel rm [deployment-url]

# Open in browser
vercel open
```

---

## Pricing

- **Hobby (Free):**
  - 100 GB bandwidth
  - Unlimited sites
  - SSL included
  - Custom domains

- **Pro ($20/month):**
  - 1 TB bandwidth
  - Advanced analytics

---

## Additional Resources

- [Vercel Documentation](https://vercel.com/docs)
- [Vercel Support](https://vercel.com/support)

---

[← Back to Main README](../README.md)

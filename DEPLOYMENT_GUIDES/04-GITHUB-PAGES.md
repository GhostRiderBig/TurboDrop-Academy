# Deploying to GitHub Pages

[GitHub Pages](https://pages.github.com/) offers free static website hosting directly from your GitHub repository.

## Prerequisites

- GitHub account (free)
- Git installed locally
- Your landing page files

## Features

- ✅ Free hosting
- ✅ Free SSL (HTTPS)
- ✅ Custom domain support
- ✅ Auto-deploy on git push
- ⚠️ Public repositories only (for free accounts)

---

## Deployment Steps

### 1. Create GitHub Repository

```bash
# Navigate to your landing page folder
cd /path/to/landing-page

# Initialize git
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit"
```

### 2. Create Repo on GitHub

- Go to [GitHub](https://github.com/new)
- Repository name: `my-landing-page` (or any name)
- Make it Public
- **Don't** initialize with README
- Click "Create repository"

### 3. Push to GitHub

```bash
# Add remote
git remote add origin https://github.com/yourusername/my-landing-page.git

# Push
git branch -M main
git push -u origin main
```

### 4. Enable GitHub Pages

- Go to repository on GitHub
- Click "Settings"
- Scroll to "Pages" section (left sidebar)
- Under "Source":
  - Branch: `main`
  - Folder: `/ (root)`
- Click "Save"

### 5. Wait for Deployment

- Takes 1-5 minutes
- Green checkmark appears when done
- Site URL: `https://yourusername.github.io/my-landing-page/`

---

## Custom Domain Setup

### Using Custom Domain (e.g., example.com)

1. **In GitHub Repository Settings → Pages:**
   - Enter custom domain: `example.com`
   - Click "Save"
   - Check "Enforce HTTPS" (after DNS propagates)

2. **Update DNS Records:**

   **For apex domain (example.com):**
   ```
   Type    Name    Value
   A       @       185.199.108.153
   A       @       185.199.109.153
   A       @       185.199.110.153
   A       @       185.199.111.153
   ```

   **For www subdomain:**
   ```
   Type     Name    Value
   CNAME    www     yourusername.github.io
   ```

3. **Wait for DNS Propagation**
   - Can take 5 minutes to 48 hours
   - Check with [DNS Checker](https://dnschecker.org)

4. **Enable HTTPS**
   - After DNS propagates, check "Enforce HTTPS" in Pages settings

---

## Using Username.github.io

For site at `https://yourusername.github.io` (no repo name):

1. Create repo named exactly: `yourusername.github.io`
2. Push files to `main` branch
3. GitHub Pages auto-enables
4. Site available at `https://yourusername.github.io`

---

## Updating Your Site

```bash
# Make changes to files
# Then:
git add .
git commit -m "Update content"
git push

# GitHub automatically rebuilds and deploys!
```

---

## Deploy from Subfolder

If your files are in a subfolder (e.g., `/docs`):

1. Move files to `/docs` folder
2. In GitHub Pages settings:
   - Branch: `main`
   - Folder: `/docs`
3. Save

---

## Using GitHub Actions (Advanced)

For more control, use GitHub Actions workflow.

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: .
```

---

## Troubleshooting

### Issue: 404 Error
**Solutions:**
- Wait 5 minutes after enabling Pages
- Check branch and folder are correct
- Ensure `index.html` exists in root

### Issue: Changes Not Showing
**Solutions:**
- Clear browser cache (Ctrl+Shift+R)
- Check GitHub Actions tab for deployment status
- Wait a few minutes for CDN to update

### Issue: Custom Domain Not Working
**Solutions:**
- Verify DNS records with [DNS Checker](https://dnschecker.org)
- Wait up to 48 hours for DNS propagation
- Ensure CNAME file exists in repo root (GitHub creates this)
- Check domain is not already used by another GitHub Pages site

### Issue: HTTPS Not Available
**Solutions:**
- Wait for DNS to fully propagate
- Uncheck and recheck "Enforce HTTPS"
- Wait 24 hours and try again

### Issue: Site Shows Old Content
**Solutions:**
- Clear browser cache
- Check latest commit deployed (Settings → Pages shows deployment status)
- Force refresh: Ctrl+Shift+R (Windows/Linux) or Cmd+Shift+R (Mac)

---

## Limitations

- **Public Repos Only** (free accounts)
  - Private repos require GitHub Pro ($4/month)
- **1 GB soft limit** (plenty for static sites)
- **100 GB bandwidth/month** (soft limit)
- **10 builds/hour** (usually more than enough)

---

## Tips

### 1. Use GitHub Desktop (GUI)
- Download: [desktop.github.com](https://desktop.github.com/)
- Easier than command line for beginners

### 2. Branch Protection
- Protect `main` branch from accidental changes
- Settings → Branches → Add rule

### 3. Custom 404 Page
- Create `404.html` in root
- GitHub automatically uses it

### 4. Use Actions for More Control
- Custom build steps
- Deploy to different branches
- Environment-specific deployments

---

## Alternatives to GitHub Pages

If you hit limitations:
- **Netlify** - More generous limits, easier deployment
- **Vercel** - Great for frameworks
- **Cloudflare Pages** - Faster global deployment

---

## Useful Commands

```bash
# Check remote URL
git remote -v

# Change remote URL
git remote set-url origin https://github.com/yourusername/new-repo.git

# View commit history
git log --oneline

# Create new branch
git checkout -b new-branch

# Switch branches
git checkout main

# Pull latest changes
git pull origin main
```

---

## Resources

- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Custom Domain Setup](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site)
- [GitHub Actions](https://docs.github.com/en/actions)

---

[← Back to Main README](../README.md)

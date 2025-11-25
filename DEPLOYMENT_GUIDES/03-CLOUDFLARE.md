# Deploying to Cloudflare Pages

[Cloudflare Pages](https://pages.cloudflare.com/) provides fast, secure, and free static site hosting on Cloudflare's global edge network.

## Why Cloudflare Pages?

- ✅ **Fastest** - Deployed on 200+ edge locations worldwide
- ✅ **Free** - Unlimited sites and requests
- ✅ **DDoS Protection** - Built-in security
- ✅ **Auto SSL** - Free HTTPS certificates
- ✅ **Git Integration** - Deploy from GitHub/GitLab

---

## Method 1: Git-Based Deployment (Recommended)

### Prerequisites
- GitHub or GitLab account
- Cloudflare account (free)

### Steps:

1. **Push to Git**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/yourusername/repo.git
   git push -u origin main
   ```

2. **Login to Cloudflare**
   - Go to [dash.cloudflare.com](https://dash.cloudflare.com)
   - Sign up or login

3. **Create Pages Project**
   - Click "Workers & Pages" in sidebar
   - Click "Create application" → "Pages" tab
   - Click "Connect to Git"

4. **Connect Repository**
   - Authorize Cloudflare to access GitHub/GitLab
   - Select your repository

5. **Configure Build Settings**
   - **Project name:** my-landing-page
   - **Production branch:** main
   - **Build command:** Leave blank
   - **Build output directory:** `/` or `.`

6. **Deploy**
   - Click "Save and Deploy"
   - Wait 1-2 minutes

7. **Get Your URL**
   ```
   https://my-landing-page.pages.dev
   ```

### Auto-Deploy
Every `git push` triggers automatic deployment!

---

## Method 2: Wrangler CLI

### Install Wrangler

```bash
npm install -g wrangler
```

### Deploy

```bash
# Login
wrangler login

# Deploy
wrangler pages deploy . --project-name=my-landing
```

### Update

```bash
wrangler pages deploy . --project-name=my-landing
```

---

## Method 3: Direct Upload (Drag & Drop)

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Click "Workers & Pages" → "Create application" → "Pages"
3. Click "Upload assets"
4. Drag folder or select files
5. Click "Deploy site"

**Note:** Limited to 1000 files and 25MB per file.

---

## Custom Domain Setup

### Option A: Domain Already on Cloudflare

1. **In Pages Project:**
   - Go to "Custom domains"
   - Click "Set up a custom domain"
   - Enter domain: `example.com`
   - Click "Continue"

2. **Cloudflare Auto-Configures DNS**
   - DNS records created automatically
   - SSL certificate provisioned automatically
   - Site live in 1-5 minutes

### Option B: External Domain

1. **In Pages Project:**
   - Go to "Custom domains"
   - Add domain: `example.com`

2. **Update DNS at Registrar:**
   ```
   Type     Name    Value
   CNAME    @       my-landing-page.pages.dev
   CNAME    www     my-landing-page.pages.dev
   ```

   Or use A records:
   ```
   Type    Name    Value
   A       @       [Cloudflare IP from dashboard]
   ```

3. **Wait for DNS Propagation**
   - Usually 5-15 minutes
   - SSL automatically provisioned

---

## Environment Variables

1. Go to project "Settings" → "Environment variables"
2. Add variables for Production/Preview
3. Redeploy to apply

---

## Branch Previews

Cloudflare automatically creates preview URLs for branches:

```bash
git checkout -b feature-update
git push origin feature-update

# Preview URL: https://feature-update.my-landing-page.pages.dev
```

---

## Redirects and Headers

Create `_redirects` file in root:

```
# Redirect examples
/old-page  /new-page  301
/blog/*    https://blog.example.com/:splat  301

# Proxying
/api/*     https://api.example.com/:splat  200
```

Create `_headers` file in root:

```
/*
  X-Frame-Options: SAMEORIGIN
  X-Content-Type-Options: nosniff
  X-XSS-Protection: 1; mode=block

/*.css
  Cache-Control: public, max-age=31536000, immutable

/*.js
  Cache-Control: public, max-age=31536000, immutable
```

---

## Functions (Serverless)

Add serverless functions in `/functions` folder:

```javascript
// functions/api/hello.js
export async function onRequest(context) {
  return new Response("Hello from Cloudflare!");
}
```

Accessible at: `https://your-site.pages.dev/api/hello`

---

## Troubleshooting

### Issue: Build fails
**Solution:** Ensure build command is blank for static sites

### Issue: Custom domain not working
**Solution:**
- Check DNS records
- Wait for propagation
- Use Cloudflare DNS for faster setup

### Issue: SSL pending
**Solution:** Wait 5-15 minutes, SSL is automatic

### Issue: Old content showing
**Solution:**
- Purge cache: Settings → Caching → Purge Everything
- Wait a few minutes

---

## Advanced: Web Analytics

Free privacy-first analytics:

1. Go to "Web Analytics" in Cloudflare dashboard
2. Add your site
3. Copy JavaScript snippet
4. Add to `index.html` before `</body>`

---

## Useful CLI Commands

```bash
# List projects
wrangler pages project list

# View deployments
wrangler pages deployment list

# Tail logs
wrangler pages deployment tail

# Delete deployment
wrangler pages deployment delete [deployment-id]
```

---

## Pricing

**Free Tier:**
- Unlimited sites
- Unlimited requests
- Unlimited bandwidth
- 500 builds/month
- 100 custom domains/project

**Paid Tier ($20/month):**
- 5000 builds/month
- Advanced features

**For landing pages, free tier is perfect!**

---

## Performance Tips

1. **Use Cloudflare CDN**
   - Already enabled by default
   - 200+ edge locations

2. **Enable Auto Minify**
   - Dashboard → Speed → Optimization
   - Enable HTML, CSS, JS minification

3. **Enable Brotli**
   - Better compression than gzip
   - Enabled by default

4. **Use Rocket Loader** (optional)
   - Speeds up JavaScript loading
   - Dashboard → Speed → Optimization

---

## Comparison with Alternatives

| Feature | Cloudflare Pages | Netlify | Vercel |
|---------|-----------------|---------|--------|
| Free bandwidth | Unlimited | 100 GB | 100 GB |
| Free builds | 500/mo | 300/mo | 6000 min/mo |
| Edge locations | 200+ | 6 | 100+ |
| DDoS protection | ✅ | Limited | Limited |
| Best for | Speed & security | Ease of use | Next.js |

---

## Resources

- [Cloudflare Pages Docs](https://developers.cloudflare.com/pages/)
- [Wrangler CLI Docs](https://developers.cloudflare.com/workers/wrangler/)
- [Cloudflare Community](https://community.cloudflare.com/)

---

[← Back to Main README](../README.md)

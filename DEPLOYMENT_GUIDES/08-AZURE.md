# Deploying to Azure Static Web Apps

Azure Static Web Apps provides free hosting for static sites with global CDN, custom domains, and automatic SSL.

## Prerequisites

- Azure account (free tier available)
- Azure CLI (optional)
- Git + GitHub/Azure DevOps account (for Git deployment)

---

## Method 1: Azure Portal (Web Interface)

### Step 1: Create Static Web App

1. **Login to Azure Portal**
   - Go to [portal.azure.com](https://portal.azure.com)
   - Sign in

2. **Create Resource**
   - Click "Create a resource"
   - Search "Static Web Apps"
   - Click "Create"

3. **Configure Basic Settings**
   - Subscription: Select your subscription
   - Resource group: Create new or select existing
   - Name: `my-landing-page`
   - Plan type: **Free**
   - Region: Choose closest to users
   - Source: GitHub or Azure DevOps

4. **Connect Repository** (if using Git)
   - Authorize Azure to access GitHub
   - Select organization, repository, and branch
   - Build presets: **Custom**
   - App location: `/`
   - Output location: Leave blank

5. **Review and Create**
   - Click "Review + create"
   - Click "Create"
   - Wait 2-3 minutes for deployment

6. **Get URL**
   ```
   https://wonderful-field-123456.azurestaticapps.net
   ```

---

## Method 2: Azure CLI

### Install Azure CLI

```bash
# macOS
brew install azure-cli

# Linux
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Windows
# Download from docs.microsoft.com/cli/azure/install-azure-cli
```

### Deploy

```bash
# Login
az login

# Create resource group (if needed)
az group create \
  --name my-landing-rg \
  --location eastus

# Create static web app
az staticwebapp create \
  --name my-landing-page \
  --resource-group my-landing-rg \
  --source https://github.com/yourusername/your-repo \
  --location eastus \
  --branch main \
  --app-location "/" \
  --output-location "" \
  --login-with-github
```

---

## Method 3: Direct Upload (No Git)

### Using Azure Static Web Apps CLI

```bash
# Install SWA CLI
npm install -g @azure/static-web-apps-cli

# Login to Azure
az login

# Deploy
swa deploy /path/to/landing-page \
  --app-name my-landing-page \
  --resource-group my-landing-rg \
  --env production
```

---

## Method 4: Azure Storage (Alternative)

For simple static hosting without CI/CD:

### Via Portal

1. **Create Storage Account**
   - Create resource → Storage account
   - Name: `mylandingstorage`
   - Performance: Standard
   - Redundancy: LRS
   - Click "Review + create"

2. **Enable Static Website**
   - Go to storage account → "Static website"
   - Enable static website
   - Index document: `index.html`
   - Error document: `index.html`
   - Save

3. **Upload Files**
   - Go to "$web" container
   - Upload all files

4. **Get URL**
   ```
   https://mylandingstorage.z13.web.core.windows.net
   ```

### Via CLI

```bash
# Create storage account
az storage account create \
  --name mylandingstorage \
  --resource-group my-landing-rg \
  --location eastus \
  --sku Standard_LRS

# Enable static website
az storage blob service-properties update \
  --account-name mylandingstorage \
  --static-website \
  --index-document index.html \
  --404-document index.html

# Upload files
az storage blob upload-batch \
  --account-name mylandingstorage \
  --destination '$web' \
  --source /path/to/landing-page
```

---

## Custom Domain Setup

### For Static Web Apps

1. **Go to Static Web App → Custom domains**
2. **Add custom domain**
   - Enter domain: `example.com`
   - Click "Next"

3. **Add DNS Records**

   Azure automatically detects if you use Azure DNS:
   ```
   Type     Name    Value
   CNAME    www     wonderful-field-123456.azurestaticapps.net
   TXT      @       [verification code from Azure]
   ```

   For apex domain (@):
   ```
   Type      Name    Value
   ALIAS     @       wonderful-field-123456.azurestaticapps.net
   ```

4. **Validate and Create**
   - Click "Add"
   - Wait for validation (5-30 minutes)
   - SSL automatically provisioned

### For Storage Account

Use Azure CDN for custom domain + SSL:

```bash
# Create CDN profile
az cdn profile create \
  --name my-landing-cdn \
  --resource-group my-landing-rg \
  --sku Standard_Microsoft

# Create CDN endpoint
az cdn endpoint create \
  --name my-landing \
  --profile-name my-landing-cdn \
  --resource-group my-landing-rg \
  --origin mylandingstorage.z13.web.core.windows.net
```

---

## Environment Variables

For Static Web Apps with API functions:

1. Go to "Configuration" in Azure Portal
2. Add application settings
3. Redeploy to apply

---

## Staging Environments

Static Web Apps automatically creates staging environments for pull requests:

```bash
# Pull request creates:
https://wonderful-field-123456-pr-5.azurestaticapps.net
```

---

## Updating Your Site

### Git-Based Deployment
```bash
git add .
git commit -m "Update content"
git push

# Azure automatically rebuilds and deploys!
```

### Direct Upload (Storage)
```bash
az storage blob upload-batch \
  --account-name mylandingstorage \
  --destination '$web' \
  --source /path/to/landing-page \
  --overwrite
```

---

## Troubleshooting

### Issue: Build fails
**Solution:** Ensure app location and output location are correct

### Issue: Custom domain not working
**Solution:**
- Verify DNS records with `nslookup`
- Wait up to 48 hours for DNS propagation
- Check TXT record for domain validation

### Issue: 404 errors
**Solution:** Set error document to `index.html` for SPA routing

---

## Pricing

### Static Web Apps
- **Free Tier:**
  - 100 GB bandwidth/month
  - 0.5 GB storage
  - Custom domains + SSL
  - Staging environments

- **Standard Tier ($9/month):**
  - 100 GB bandwidth (then $0.20/GB)
  - Advanced features

### Storage Account
- **Storage:** $0.018/GB per month
- **Bandwidth:** $0.087/GB (first 10TB)
- **CDN:** $0.081/GB + $0.0075 per 10k requests

---

## Performance Optimization

### Enable CDN (for Storage)

Already included in Static Web Apps.

For Storage accounts:
```bash
az cdn profile create --name my-cdn --resource-group my-rg
```

### Compression

Static Web Apps automatically enables gzip/brotli compression.

---

## Monitoring

### Application Insights (Optional)

```bash
# Create Application Insights
az monitor app-insights component create \
  --app my-landing-insights \
  --location eastus \
  --resource-group my-landing-rg
```

Link to Static Web App in portal settings.

---

## Useful Commands

```bash
# List static web apps
az staticwebapp list

# Show app details
az staticwebapp show \
  --name my-landing-page \
  --resource-group my-landing-rg

# List custom domains
az staticwebapp hostname list \
  --name my-landing-page \
  --resource-group my-landing-rg

# View deployment token
az staticwebapp secrets list \
  --name my-landing-page \
  --resource-group my-landing-rg
```

---

## GitHub Actions Integration

Azure automatically creates GitHub Actions workflow:

`.github/workflows/azure-static-web-apps-[name].yml`

You can customize build steps there.

---

## Comparison

| Feature | Static Web Apps | Storage + CDN |
|---------|----------------|---------------|
| Price | Free tier available | ~$2-5/month |
| Setup | Easier | More manual |
| Git Deploy | Yes | No |
| Custom domain | Easy | Requires CDN |
| Best for | Modern apps | Simple sites |

---

## Resources

- [Azure Static Web Apps Docs](https://docs.microsoft.com/azure/static-web-apps/)
- [Azure Storage Static Website](https://docs.microsoft.com/azure/storage/blobs/storage-blob-static-website)
- [Azure CLI Reference](https://docs.microsoft.com/cli/azure/)

---

[← Back to Main README](../README.md)

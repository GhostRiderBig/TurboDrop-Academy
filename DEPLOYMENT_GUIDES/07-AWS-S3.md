# Deploying to AWS S3

Amazon S3 can host static websites with global CDN (CloudFront) distribution.

## Prerequisites

- AWS account
- AWS CLI installed
- Domain name (optional)

---

## Method 1: AWS Console (Web Interface)

### Step 1: Create S3 Bucket

1. **Login to AWS Console**
   - Go to [aws.amazon.com](https://aws.amazon.com)
   - Sign in to Console

2. **Create Bucket**
   - Go to S3 service
   - Click "Create bucket"
   - Bucket name: `my-landing-page` (must be globally unique)
   - Region: Choose closest to users
   - Uncheck "Block all public access"
   - Click "Create bucket"

### Step 2: Upload Files

1. Open your bucket
2. Click "Upload"
3. Drag all files and folders
4. Click "Upload"

### Step 3: Enable Static Website Hosting

1. Go to bucket → "Properties"
2. Scroll to "Static website hosting"
3. Click "Edit"
4. Enable: "Static website hosting"
5. Index document: `index.html`
6. Error document: `index.html`
7. Click "Save changes"
8. Note the endpoint URL

### Step 4: Set Bucket Policy (Make Public)

1. Go to "Permissions" tab
2. Scroll to "Bucket policy"
3. Click "Edit"
4. Paste this policy (replace `my-landing-page`):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-landing-page/*"
    }
  ]
}
```

5. Click "Save changes"

### Step 5: Access Your Site

```
http://my-landing-page.s3-website-us-east-1.amazonaws.com
```

---

## Method 2: AWS CLI

### Install AWS CLI

```bash
# macOS
brew install awscli

# Linux
sudo apt install awscli

# Windows
# Download from aws.amazon.com/cli/
```

### Configure AWS CLI

```bash
aws configure
# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (e.g., us-east-1)
# - Output format: json
```

### Deploy

```bash
# Create bucket
aws s3 mb s3://my-landing-page

# Upload files
aws s3 sync /path/to/landing-page s3://my-landing-page \
  --exclude "*.sh" \
  --exclude "*.md" \
  --exclude "DEPLOYMENT_GUIDES/*"

# Enable website hosting
aws s3 website s3://my-landing-page \
  --index-document index.html \
  --error-document index.html

# Set bucket policy for public access
aws s3api put-bucket-policy \
  --bucket my-landing-page \
  --policy file://policy.json
```

Create `policy.json`:
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "PublicReadGetObject",
    "Effect": "Allow",
    "Principal": "*",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::my-landing-page/*"
  }]
}
```

---

## Adding CloudFront CDN (Recommended)

CloudFront provides HTTPS and global caching.

### Via AWS Console

1. **Create Distribution**
   - Go to CloudFront service
   - Click "Create distribution"
   - Origin domain: Select your S3 bucket
   - Viewer protocol policy: "Redirect HTTP to HTTPS"
   - Default root object: `index.html`
   - Click "Create distribution"

2. **Wait for Deployment** (10-15 minutes)

3. **Get CloudFront URL**
   ```
   https://d1234abcd.cloudfront.net
   ```

### Via CLI

```bash
aws cloudfront create-distribution \
  --origin-domain-name my-landing-page.s3.amazonaws.com \
  --default-root-object index.html
```

---

## Custom Domain Setup

### Step 1: Request SSL Certificate (ACM)

```bash
# Must be in us-east-1 for CloudFront
aws acm request-certificate \
  --domain-name example.com \
  --domain-name www.example.com \
  --validation-method DNS \
  --region us-east-1
```

### Step 2: Validate Certificate

1. Go to ACM console
2. Note the CNAME records
3. Add to your DNS

### Step 3: Add Custom Domain to CloudFront

1. Edit CloudFront distribution
2. Add alternate domain names:
   - `example.com`
   - `www.example.com`
3. Select ACM certificate
4. Save changes

### Step 4: Update DNS

```
Type     Name    Value
CNAME    @       d1234abcd.cloudfront.net
CNAME    www     d1234abcd.cloudfront.net
```

Or use Route 53 (AWS DNS):
```
Type      Name    Alias Target
A         @       Yes → CloudFront distribution
A         www     Yes → CloudFront distribution
```

---

## Updating Your Site

### Via Console
1. Upload new files (overwrites old)
2. Invalidate CloudFront cache (if using):
   - Go to CloudFront → Invalidations
   - Create invalidation: `/*`

### Via CLI

```bash
# Sync changes
aws s3 sync /path/to/landing-page s3://my-landing-page --delete

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id E1234ABCD \
  --paths "/*"
```

---

## Pricing

### S3 Costs
- **Storage:** $0.023/GB per month
- **Requests:** $0.0004 per 1,000 GET requests
- **Transfer:** $0.09/GB (first 10TB)

**Example:** 500MB site with 10,000 visitors/month ≈ **$1-2/month**

### CloudFront Costs
- **Data Transfer:** $0.085/GB (first 10TB)
- **Requests:** $0.0075 per 10,000 HTTPS requests
- **Free tier:** 50GB/month for 12 months

**Example:** 10,000 visitors/month ≈ **$1-3/month**

---

## Optimization

### Enable Gzip Compression

When uploading files:

```bash
aws s3 sync . s3://my-landing-page \
  --exclude "*" \
  --include "*.html" \
  --include "*.css" \
  --include "*.js" \
  --content-encoding gzip \
  --metadata-directive REPLACE
```

### Set Cache Headers

```bash
# Cache images for 1 year
aws s3 cp images/ s3://my-landing-page/images/ \
  --recursive \
  --cache-control "max-age=31536000,public"

# No cache for HTML
aws s3 cp index.html s3://my-landing-page/ \
  --cache-control "no-cache,no-store,must-revalidate"
```

---

## Troubleshooting

### Issue: 403 Forbidden
**Solution:** Check bucket policy is set and public access is allowed

### Issue: 404 Not Found
**Solution:**
- Ensure index.html exists
- Check static website hosting is enabled
- Verify error document is set

### Issue: Changes not showing
**Solution:** Invalidate CloudFront cache

### Issue: No HTTPS
**Solution:** Use CloudFront (S3 static hosting doesn't support HTTPS)

---

## Automation Scripts

### deploy.sh (S3 Only)

```bash
#!/bin/bash
BUCKET="my-landing-page"

aws s3 sync . s3://$BUCKET \
  --exclude ".git/*" \
  --exclude "*.sh" \
  --exclude "*.md" \
  --exclude "DEPLOYMENT_GUIDES/*" \
  --delete

echo "Deployed to: http://$BUCKET.s3-website-$(aws configure get region).amazonaws.com"
```

### deploy-cdn.sh (S3 + CloudFront)

```bash
#!/bin/bash
BUCKET="my-landing-page"
DISTRIBUTION_ID="E1234ABCD"

# Upload to S3
aws s3 sync . s3://$BUCKET --delete

# Invalidate CloudFront
aws cloudfront create-invalidation \
  --distribution-id $DISTRIBUTION_ID \
  --paths "/*"

echo "Deployed and cache invalidated!"
```

---

## Alternative: AWS Amplify

For even easier deployment, consider AWS Amplify:

```bash
# Install Amplify CLI
npm install -g @aws-amplify/cli

# Initialize
amplify init

# Add hosting
amplify add hosting

# Deploy
amplify publish
```

---

## Resources

- [S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/)

---

[← Back to Main README](../README.md)

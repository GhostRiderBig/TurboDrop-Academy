# Deploying to cPanel Hosting

cPanel is the most popular control panel for shared hosting. If you have shared hosting (GoDaddy, Bluehost, HostGator, etc.), you likely have cPanel.

## Prerequisites

- cPanel hosting account
- Domain name (or use hosting provider's subdomain)
- FTP credentials (optional, for alternative method)

---

## Method 1: File Manager (Recommended)

This is the easiest way to deploy to cPanel hosting.

### Deploy to Root Domain (example.com)

1. **Login to cPanel**
   - Go to your hosting provider's cPanel login (usually `yourdomain.com/cpanel` or `yourdomain.com:2083`)
   - Enter username and password

2. **Open File Manager**
   - Find "File Manager" in the "Files" section
   - Click to open

3. **Navigate to public_html**
   - Click on `public_html` folder in left sidebar
   - This is your website's root directory

4. **Clear Existing Files (if needed)**
   - If there are default files (index.html, etc.), select and delete them
   - Keep: `.htaccess`, `cgi-bin`, and any other important files

5. **Upload Your Files**

   **Option A: Upload Zip**
   - Click "Upload" button
   - Select your landing page zip file
   - Wait for upload to complete
   - Go back to File Manager
   - Right-click the zip file → "Extract"
   - Extract to `public_html/`
   - Delete the zip file

   **Option B: Upload Files Directly**
   - Click "Upload" button
   - Select all files: `index.html`, `style.css`, `script.js`, `_privacy.html`, `_terms.html`
   - Also select the `images` folder
   - Wait for upload to complete

6. **Set Permissions**
   - Select all uploaded files
   - Click "Permissions" button
   - Set files to `644`
   - Set folders to `755`

7. **Visit Your Site**
   - Open `https://yourdomain.com`
   - Your landing page is live!

### Deploy to Subfolder (example.com/landing)

1. **Follow steps 1-3 above**

2. **Create Subfolder**
   - In `public_html/`, click "+ Folder"
   - Name it (e.g., `landing`)
   - Open the new folder

3. **Upload Files**
   - Upload all files to this subfolder (see step 5 above)

4. **Set Permissions** (step 6 above)

5. **Visit Your Site**
   - Open `https://yourdomain.com/landing`

---

## Method 2: FTP Upload

If you prefer using an FTP client like FileZilla.

### Steps:

1. **Get FTP Credentials**
   - In cPanel, go to "FTP Accounts"
   - Create FTP account or use main account credentials
   - Note: hostname, username, password, port

2. **Connect with FTP Client**

   **Using FileZilla:**
   - Host: `ftp.yourdomain.com` or your server IP
   - Username: your FTP username
   - Password: your FTP password
   - Port: `21`

3. **Navigate to public_html**
   - In the remote site panel, open `public_html/`

4. **Upload Files**
   - Drag all files from local panel to remote panel
   - Wait for transfer to complete

5. **Visit Your Site**
   - Open `https://yourdomain.com`

---

## Setting Up SSL (HTTPS)

Most cPanel hosts offer free SSL via Let's Encrypt.

### Steps:

1. **Go to SSL/TLS Status**
   - In cPanel, search for "SSL/TLS Status"
   - Click to open

2. **Enable AutoSSL**
   - Check your domain
   - Click "Run AutoSSL"
   - Wait 1-5 minutes for certificate installation

3. **Force HTTPS (Optional)**
   - Edit `.htaccess` file in `public_html/`
   - Add at the top:
     ```apache
     RewriteEngine On
     RewriteCond %{HTTPS} off
     RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
     ```
   - Or use the included `.htaccess` (already has this, just uncomment)

4. **Verify**
   - Visit `https://yourdomain.com`
   - Check for padlock icon in browser

---

## Custom Domain Setup

### If You Bought Domain from Different Registrar:

1. **Add Domain in cPanel**
   - Go to "Addon Domains" or "Parked Domains"
   - Enter your domain name
   - Save

2. **Update Nameservers**
   - At your domain registrar, update nameservers to your host's nameservers
   - Find nameservers in cPanel welcome email or ask support

3. **Wait for Propagation**
   - Can take 1-48 hours
   - Check with [DNS Checker](https://dnschecker.org)

---

## Troubleshooting

### Issue: 404 Error - Page Not Found
**Solutions:**
- Ensure `index.html` exists in correct directory
- Check file name is exactly `index.html` (case-sensitive on Linux)
- Verify domain points to correct directory in cPanel

### Issue: Images/CSS Not Loading
**Solutions:**
- Check file paths are relative (`./images/photo.jpg` not `/images/photo.jpg`)
- Verify file permissions: files `644`, folders `755`
- Check file names match exactly (case-sensitive)

### Issue: Permission Denied
**Solutions:**
- Set correct permissions: `chmod 644` for files, `chmod 755` for folders
- Contact hosting support if issues persist

### Issue: Site Shows "Coming Soon" or Default Page
**Solutions:**
- Delete default `index.html` or `coming-soon.html` files
- Ensure your `index.html` is in the root of `public_html/`

### Issue: Cannot Access cPanel
**Solutions:**
- Try alternative URL: `yourdomain.com:2083` or `yourdomain.com/cpanel`
- Check welcome email from hosting provider for correct URL
- Contact hosting support

---

## Performance Optimization

### 1. Enable Gzip Compression
The included `.htaccess` file already enables gzip compression.

### 2. Use Cloudflare (Optional)
- Free CDN and performance boost
- Sign up at [Cloudflare.com](https://www.cloudflare.com)
- Add your site
- Update nameservers
- Enable "Auto Minify" and "Brotli" compression

### 3. Optimize Images
Your images are already optimized (webp format), but you can:
- Use tinypng.com for further compression
- Ensure images are properly sized

---

## Updating Your Site

### Method 1: File Manager
1. Login to cPanel
2. Open File Manager
3. Navigate to your files
4. Upload new files (overwrite existing)

### Method 2: FTP
1. Connect via FTP
2. Upload updated files
3. Overwrite when prompted

### Quick Update:
- Just upload the specific files you changed
- No need to re-upload everything

---

## Backup Your Site

### Manual Backup:

1. **Via cPanel File Manager:**
   - Select `public_html` folder
   - Click "Compress"
   - Choose "Zip Archive"
   - Download the zip file

2. **Via cPanel Backup:**
   - Go to "Backup" in cPanel
   - Click "Download a Home Directory Backup"
   - Wait for email with download link

### Automated Backup:
- Most hosts offer automated backups
- Check with your hosting provider

---

## Popular cPanel Hosts

- **Bluehost** - [bluehost.com](https://www.bluehost.com)
- **HostGator** - [hostgator.com](https://www.hostgator.com)
- **GoDaddy** - [godaddy.com](https://www.godaddy.com)
- **SiteGround** - [siteground.com](https://www.siteground.com)
- **A2 Hosting** - [a2hosting.com](https://www.a2hosting.com)
- **InMotion** - [inmotionhosting.com](https://www.inmotionhosting.com)

---

## Additional Resources

- [cPanel Documentation](https://docs.cpanel.net/)
- [FileZilla Documentation](https://wiki.filezilla-project.org/Documentation)

---

[← Back to Main README](../README.md)

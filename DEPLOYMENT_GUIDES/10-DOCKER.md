# Deploying with Docker

Docker allows you to containerize your landing page for portable, consistent deployment across any platform.

## Prerequisites

- Docker installed ([Get Docker](https://docs.docker.com/get-docker/))
- Docker Compose installed (included with Docker Desktop)

---

## Quick Start (Fastest)

```bash
# Navigate to landing page directory
cd /path/to/landing-page

# Start with docker-compose
docker-compose up -d

# Your site is now running at http://localhost:8080
```

That's it! Your landing page is running in Docker.

---

## Method 1: Docker Compose (Recommended)

The easiest way to run your landing page with Docker.

### Steps:

1. **Start Container**
   ```bash
   docker-compose up -d
   ```

   This will:
   - Build the Docker image
   - Start nginx container
   - Expose port 8080

2. **View Your Site**
   - Open browser: `http://localhost:8080`

3. **Custom Port**
   ```bash
   PORT=3000 docker-compose up -d
   ```
   - Site available at: `http://localhost:3000`

4. **Custom Domain** (for production)
   ```bash
   DOMAIN=example.com docker-compose up -d
   ```

### Managing Container:

```bash
# View logs
docker-compose logs -f

# Stop container
docker-compose down

# Restart container
docker-compose restart

# Rebuild and start
docker-compose up -d --build

# View status
docker-compose ps
```

---

## Method 2: Plain Docker (Without Compose)

### Build Image:

```bash
docker build -t landing-page .
```

### Run Container:

```bash
docker run -d \
  --name landing-page \
  -p 8080:80 \
  --restart unless-stopped \
  landing-page
```

### Manage Container:

```bash
# View logs
docker logs -f landing-page

# Stop
docker stop landing-page

# Start
docker start landing-page

# Remove
docker rm -f landing-page

# View status
docker ps
```

---

## Production Deployment

### With SSL/HTTPS

For production with SSL, use a reverse proxy like Traefik or nginx-proxy.

#### Using nginx-proxy with Let's Encrypt:

1. **Create docker-compose.yml**

```yaml
version: '3.8'

services:
  nginx-proxy:
    image: nginxproxy/nginx-proxy
    container_name: nginx-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - certs:/etc/nginx/certs
      - vhost:/etc/nginx/vhost.d
      - html:/usr/share/nginx/html
    networks:
      - proxy

  letsencrypt:
    image: nginxproxy/acme-companion
    container_name: letsencrypt
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - certs:/etc/nginx/certs
      - vhost:/etc/nginx/vhost.d
      - html:/usr/share/nginx/html
      - acme:/etc/acme.sh
    environment:
      - DEFAULT_EMAIL=your-email@example.com
    networks:
      - proxy

  landing:
    build: .
    container_name: landing-page
    expose:
      - 80
    environment:
      - VIRTUAL_HOST=example.com,www.example.com
      - LETSENCRYPT_HOST=example.com,www.example.com
      - LETSENCRYPT_EMAIL=your-email@example.com
    networks:
      - proxy
    restart: unless-stopped

volumes:
  certs:
  vhost:
  html:
  acme:

networks:
  proxy:
    driver: bridge
```

2. **Start Services**
```bash
docker-compose up -d
```

3. **Wait for SSL Certificate**
- Takes 1-5 minutes
- Site available at `https://example.com`

---

## Deployment on Cloud Platforms

### DigitalOcean

1. **Create Droplet**
   - Choose Docker marketplace image
   - Or install Docker manually

2. **SSH into Droplet**
   ```bash
   ssh root@your-droplet-ip
   ```

3. **Upload Files**
   ```bash
   # On your local machine:
   scp -r /path/to/landing-page root@your-droplet-ip:/root/
   ```

4. **Deploy**
   ```bash
   cd /root/landing-page
   docker-compose up -d
   ```

### AWS EC2

Similar to DigitalOcean:
1. Launch EC2 instance
2. Install Docker
3. Upload files
4. Run `docker-compose up -d`

### Google Cloud Run

Deploy directly from GitHub:
```bash
gcloud run deploy landing-page \
  --source . \
  --platform managed \
  --allow-unauthenticated
```

---

## Customization

### Custom Nginx Configuration

Edit `docker-nginx.conf` before building:

```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;

    # Your custom config here
}
```

Then rebuild:
```bash
docker-compose up -d --build
```

### Mount Files for Development

Uncomment volume mounts in `docker-compose.yml`:

```yaml
volumes:
  - ./index.html:/usr/share/nginx/html/index.html:ro
  - ./style.css:/usr/share/nginx/html/style.css:ro
  - ./script.js:/usr/share/nginx/html/script.js:ro
  - ./images:/usr/share/nginx/html/images:ro
```

Now changes are reflected immediately (no rebuild needed).

---

## Troubleshooting

### Issue: Port already in use
**Solution:**
```bash
# Check what's using port 80
sudo lsof -i :80

# Use different port
PORT=8080 docker-compose up -d
```

### Issue: Permission denied
**Solution:**
```bash
# Run with sudo (Linux)
sudo docker-compose up -d

# Or add user to docker group
sudo usermod -aG docker $USER
# Logout and login again
```

### Issue: Cannot connect to Docker daemon
**Solution:**
- Start Docker Desktop (Mac/Windows)
- Or start Docker service (Linux):
  ```bash
  sudo systemctl start docker
  ```

### Issue: Container keeps restarting
**Solution:**
```bash
# View logs
docker-compose logs

# Common fix: Check nginx config syntax
docker run --rm -v $(pwd)/docker-nginx.conf:/etc/nginx/conf.d/default.conf nginx nginx -t
```

---

## Performance Optimization

### 1. Multi-stage Build (Already Implemented)
Uses `nginx:alpine` for minimal image size (~23MB).

### 2. Enable Caching
Caching headers already configured in `docker-nginx.conf`.

### 3. Gzip Compression
Already enabled in nginx config.

### 4. Health Checks
Already configured in Dockerfile:
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
    CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1
```

---

## Useful Commands

```bash
# View all containers
docker ps -a

# View all images
docker images

# Remove unused images
docker image prune -a

# Remove unused volumes
docker volume prune

# View resource usage
docker stats

# Execute command in container
docker exec -it landing-page sh

# View nginx config
docker exec landing-page cat /etc/nginx/conf.d/default.conf

# Test nginx config
docker exec landing-page nginx -t

# Reload nginx
docker exec landing-page nginx -s reload
```

---

## Docker Hub (Optional)

Publish your image to Docker Hub for easy deployment.

### Steps:

1. **Tag Image**
   ```bash
   docker tag landing-page yourusername/landing-page:latest
   ```

2. **Login to Docker Hub**
   ```bash
   docker login
   ```

3. **Push Image**
   ```bash
   docker push yourusername/landing-page:latest
   ```

4. **Deploy Anywhere**
   ```bash
   docker run -d -p 8080:80 yourusername/landing-page:latest
   ```

---

## Kubernetes Deployment (Advanced)

### deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: landing-page
spec:
  replicas: 3
  selector:
    matchLabels:
      app: landing-page
  template:
    metadata:
      labels:
        app: landing-page
    spec:
      containers:
      - name: landing-page
        image: landing-page:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: landing-page
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: landing-page
```

Deploy:
```bash
kubectl apply -f deployment.yaml
```

---

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Nginx Docker Image](https://hub.docker.com/_/nginx)

---

[← Back to Main README](../README.md)

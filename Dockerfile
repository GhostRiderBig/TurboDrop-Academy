# Use lightweight Nginx Alpine image
FROM nginx:alpine

# Set maintainer
LABEL maintainer="Vsesvit.AI <support@vsesvit.ai>"
LABEL description="Static landing page built with Vsesvit.AI"

# Install curl for healthcheck
RUN apk add --no-cache curl

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx configuration
COPY docker-nginx.conf /etc/nginx/conf.d/default.conf

# Copy landing page files to nginx html directory
COPY index.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/
COPY script.js /usr/share/nginx/html/
COPY _privacy.html /usr/share/nginx/html/
COPY _terms.html /usr/share/nginx/html/
COPY images/ /usr/share/nginx/html/images/

# Set correct permissions
RUN chmod -R 755 /usr/share/nginx/html && \
    chmod -R 644 /usr/share/nginx/html/*.html /usr/share/nginx/html/*.css /usr/share/nginx/html/*.js

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

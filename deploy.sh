#!/bin/bash

#############################################################################
# Landing Page Automated Deployment Script
# Supports: Ubuntu, Debian, CentOS, macOS
# Web Servers: Apache, Nginx
# Features: Auto-detection, SSL setup, Domain/Subfolder deployment
#############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#############################################################################
# Helper Functions
#############################################################################

print_header() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║        Landing Page Automated Deployment Script           ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

confirm() {
    read -p "$1 (y/n): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

#############################################################################
# System Detection
#############################################################################

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS=$ID
            OS_VERSION=$VERSION_ID
        elif [ -f /etc/redhat-release ]; then
            OS="centos"
        else
            OS="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        OS="unknown"
    fi
}

detect_webserver() {
    if command -v nginx &> /dev/null; then
        EXISTING_WEBSERVER="nginx"
        print_info "Detected existing Nginx installation"
    elif command -v apache2 &> /dev/null || command -v httpd &> /dev/null; then
        EXISTING_WEBSERVER="apache"
        print_info "Detected existing Apache installation"
    else
        EXISTING_WEBSERVER="none"
        print_info "No web server detected"
    fi
}

#############################################################################
# Package Manager Functions
#############################################################################

update_system() {
    print_info "Updating system packages..."

    case $OS in
        ubuntu|debian)
            sudo apt update
            sudo apt upgrade -y
            ;;
        centos|rhel|fedora)
            sudo yum update -y
            ;;
        macos)
            brew update
            ;;
        *)
            print_warning "Unknown OS, skipping system update"
            ;;
    esac

    print_success "System updated"
}

install_package() {
    local package=$1

    case $OS in
        ubuntu|debian)
            sudo apt install -y $package
            ;;
        centos|rhel|fedora)
            sudo yum install -y $package
            ;;
        macos)
            brew install $package
            ;;
    esac
}

#############################################################################
# Web Server Installation
#############################################################################

install_nginx() {
    print_info "Installing Nginx..."

    case $OS in
        ubuntu|debian)
            sudo apt install -y nginx
            sudo systemctl enable nginx
            sudo systemctl start nginx
            ;;
        centos|rhel|fedora)
            sudo yum install -y nginx
            sudo systemctl enable nginx
            sudo systemctl start nginx
            ;;
        macos)
            brew install nginx
            brew services start nginx
            ;;
    esac

    print_success "Nginx installed and started"
}

install_apache() {
    print_info "Installing Apache..."

    case $OS in
        ubuntu|debian)
            sudo apt install -y apache2
            sudo systemctl enable apache2
            sudo systemctl start apache2
            ;;
        centos|rhel|fedora)
            sudo yum install -y httpd
            sudo systemctl enable httpd
            sudo systemctl start httpd
            ;;
        macos)
            brew install httpd
            brew services start httpd
            ;;
    esac

    print_success "Apache installed and started"
}

#############################################################################
# Deployment Functions
#############################################################################

deploy_nginx_root() {
    local domain=$1
    local site_path="/var/www/$domain"

    print_info "Deploying to Nginx (root domain: $domain)..."

    # Create site directory
    sudo mkdir -p "$site_path"

    # Copy files
    sudo cp -r "$SCRIPT_DIR"/* "$site_path/"

    # Set permissions
    sudo chown -R www-data:www-data "$site_path" 2>/dev/null || sudo chown -R nginx:nginx "$site_path" 2>/dev/null || true
    sudo chmod -R 755 "$site_path"

    # Create Nginx config
    local config_file="/etc/nginx/sites-available/$domain"
    sudo mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled

    sudo tee "$config_file" > /dev/null <<EOF
server {
    listen 80;
    listen [::]:80;

    server_name $domain www.$domain;
    root $site_path;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/javascript application/xml+rss application/json;

    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|webp)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
EOF

    # Enable site
    sudo ln -sf "$config_file" /etc/nginx/sites-enabled/

    # Test and reload Nginx
    sudo nginx -t
    sudo systemctl reload nginx

    print_success "Deployed to Nginx at $site_path"
    print_success "Site available at: http://$domain"
}

deploy_nginx_subfolder() {
    local base_domain=$1
    local subfolder=$2
    local site_path="/var/www/html/$subfolder"

    print_info "Deploying to Nginx (subfolder: $base_domain/$subfolder)..."

    # Create site directory
    sudo mkdir -p "$site_path"

    # Copy files
    sudo cp -r "$SCRIPT_DIR"/* "$site_path/"

    # Set permissions
    sudo chown -R www-data:www-data "$site_path" 2>/dev/null || sudo chown -R nginx:nginx "$site_path" 2>/dev/null || true
    sudo chmod -R 755 "$site_path"

    # Add location block to existing config or create new one
    local config_file="/etc/nginx/sites-available/default"
    [ -f "/etc/nginx/sites-available/$base_domain" ] && config_file="/etc/nginx/sites-available/$base_domain"

    print_info "Please add this location block to your Nginx config ($config_file):"
    echo ""
    echo "    location /$subfolder {"
    echo "        alias $site_path;"
    echo "        index index.html;"
    echo "        try_files \$uri \$uri/ /$subfolder/index.html;"
    echo "    }"
    echo ""

    if confirm "Would you like me to attempt to add this automatically?"; then
        # Backup config
        sudo cp "$config_file" "$config_file.backup"
        print_success "Config backed up to $config_file.backup"

        print_warning "Manual configuration recommended. Please edit $config_file"
    fi

    print_success "Files deployed to $site_path"
    print_success "Site will be available at: http://$base_domain/$subfolder"
}

deploy_apache_root() {
    local domain=$1
    local site_path="/var/www/$domain"

    print_info "Deploying to Apache (root domain: $domain)..."

    # Create site directory
    sudo mkdir -p "$site_path"

    # Copy files
    sudo cp -r "$SCRIPT_DIR"/* "$site_path/"

    # Set permissions
    sudo chown -R www-data:www-data "$site_path" 2>/dev/null || sudo chown -R apache:apache "$site_path" 2>/dev/null || true
    sudo chmod -R 755 "$site_path"

    # Create Apache config
    local config_file
    if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
        config_file="/etc/apache2/sites-available/$domain.conf"
        sudo tee "$config_file" > /dev/null <<EOF
<VirtualHost *:80>
    ServerName $domain
    ServerAlias www.$domain
    DocumentRoot $site_path

    <Directory $site_path>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/$domain-error.log
    CustomLog \${APACHE_LOG_DIR}/$domain-access.log combined
</VirtualHost>
EOF

        # Enable site and required modules
        sudo a2enmod rewrite
        sudo a2ensite "$domain.conf"
        sudo systemctl reload apache2

    else
        config_file="/etc/httpd/conf.d/$domain.conf"
        sudo tee "$config_file" > /dev/null <<EOF
<VirtualHost *:80>
    ServerName $domain
    ServerAlias www.$domain
    DocumentRoot $site_path

    <Directory $site_path>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog /var/log/httpd/$domain-error.log
    CustomLog /var/log/httpd/$domain-access.log combined
</VirtualHost>
EOF

        sudo systemctl reload httpd
    fi

    print_success "Deployed to Apache at $site_path"
    print_success "Site available at: http://$domain"
}

deploy_apache_subfolder() {
    local base_domain=$1
    local subfolder=$2
    local site_path="/var/www/html/$subfolder"

    print_info "Deploying to Apache (subfolder: $base_domain/$subfolder)..."

    # Create site directory
    sudo mkdir -p "$site_path"

    # Copy files
    sudo cp -r "$SCRIPT_DIR"/* "$site_path/"

    # Set permissions
    sudo chown -R www-data:www-data "$site_path" 2>/dev/null || sudo chown -R apache:apache "$site_path" 2>/dev/null || true
    sudo chmod -R 755 "$site_path"

    print_success "Files deployed to $site_path"
    print_success "Site available at: http://$base_domain/$subfolder"
    print_info "The included .htaccess file handles routing automatically"
}

#############################################################################
# SSL Setup
#############################################################################

setup_ssl() {
    local domain=$1
    local webserver=$2

    print_info "Setting up SSL certificate with Let's Encrypt..."

    # Install certbot
    case $OS in
        ubuntu|debian)
            sudo apt install -y certbot
            if [[ "$webserver" == "nginx" ]]; then
                sudo apt install -y python3-certbot-nginx
            else
                sudo apt install -y python3-certbot-apache
            fi
            ;;
        centos|rhel|fedora)
            sudo yum install -y certbot
            if [[ "$webserver" == "nginx" ]]; then
                sudo yum install -y python3-certbot-nginx
            else
                sudo yum install -y python3-certbot-apache
            fi
            ;;
        macos)
            print_warning "Let's Encrypt setup on macOS requires additional configuration"
            return
            ;;
    esac

    # Run certbot
    if [[ "$webserver" == "nginx" ]]; then
        sudo certbot --nginx -d "$domain" -d "www.$domain"
    else
        sudo certbot --apache -d "$domain" -d "www.$domain"
    fi

    # Setup auto-renewal
    (crontab -l 2>/dev/null; echo "0 3 * * * certbot renew --quiet") | crontab -

    print_success "SSL certificate installed"
    print_success "Auto-renewal configured (runs daily at 3 AM)"
}

#############################################################################
# Main Menu
#############################################################################

main_menu() {
    clear
    print_header

    echo "This script will help you deploy your landing page."
    echo ""

    # Detect OS
    detect_os
    print_info "Detected OS: $OS"

    # Detect existing web server
    detect_webserver

    echo ""
    echo "Deployment Options:"
    echo ""
    echo "1) Deploy to existing domain (root)"
    echo "2) Deploy to subfolder of existing domain"
    echo "3) Install & configure new web server"
    echo "4) Setup SSL certificate (Let's Encrypt)"
    echo "5) Exit"
    echo ""

    read -p "Select option [1-5]: " choice

    case $choice in
        1)
            deploy_root_domain
            ;;
        2)
            deploy_subfolder
            ;;
        3)
            install_webserver
            ;;
        4)
            setup_ssl_interactive
            ;;
        5)
            exit 0
            ;;
        *)
            print_error "Invalid option"
            sleep 2
            main_menu
            ;;
    esac
}

deploy_root_domain() {
    echo ""
    read -p "Enter your domain name (e.g., example.com): " domain

    if [[ -z "$domain" ]]; then
        print_error "Domain name is required"
        sleep 2
        main_menu
        return
    fi

    # Choose web server
    if [[ "$EXISTING_WEBSERVER" == "none" ]]; then
        echo ""
        echo "No web server detected. Please install one first (Option 3)."
        sleep 3
        main_menu
        return
    fi

    echo ""
    print_info "Using: $EXISTING_WEBSERVER"

    if [[ "$EXISTING_WEBSERVER" == "nginx" ]]; then
        deploy_nginx_root "$domain"
    else
        deploy_apache_root "$domain"
    fi

    echo ""
    if confirm "Would you like to setup SSL certificate now?"; then
        setup_ssl "$domain" "$EXISTING_WEBSERVER"
    fi

    echo ""
    print_success "Deployment complete!"
    print_info "Your site should be accessible at: http://$domain"
    echo ""
    read -p "Press Enter to continue..."
    main_menu
}

deploy_subfolder() {
    echo ""
    read -p "Enter base domain (e.g., example.com): " base_domain
    read -p "Enter subfolder name (e.g., landing): " subfolder

    if [[ -z "$base_domain" ]] || [[ -z "$subfolder" ]]; then
        print_error "Both domain and subfolder are required"
        sleep 2
        main_menu
        return
    fi

    if [[ "$EXISTING_WEBSERVER" == "none" ]]; then
        echo ""
        echo "No web server detected. Please install one first (Option 3)."
        sleep 3
        main_menu
        return
    fi

    echo ""
    print_info "Using: $EXISTING_WEBSERVER"

    if [[ "$EXISTING_WEBSERVER" == "nginx" ]]; then
        deploy_nginx_subfolder "$base_domain" "$subfolder"
    else
        deploy_apache_subfolder "$base_domain" "$subfolder"
    fi

    echo ""
    print_success "Deployment complete!"
    print_info "Your site should be accessible at: http://$base_domain/$subfolder"
    echo ""
    read -p "Press Enter to continue..."
    main_menu
}

install_webserver() {
    echo ""
    echo "Which web server would you like to install?"
    echo ""
    echo "1) Nginx (recommended)"
    echo "2) Apache"
    echo "3) Back to main menu"
    echo ""

    read -p "Select option [1-3]: " ws_choice

    case $ws_choice in
        1)
            if confirm "Install Nginx?"; then
                update_system
                install_nginx
                EXISTING_WEBSERVER="nginx"
                print_success "Nginx installation complete"
            fi
            ;;
        2)
            if confirm "Install Apache?"; then
                update_system
                install_apache
                EXISTING_WEBSERVER="apache"
                print_success "Apache installation complete"
            fi
            ;;
        3)
            main_menu
            return
            ;;
    esac

    echo ""
    read -p "Press Enter to continue..."
    main_menu
}

setup_ssl_interactive() {
    echo ""
    read -p "Enter your domain name: " domain

    if [[ -z "$domain" ]]; then
        print_error "Domain name is required"
        sleep 2
        main_menu
        return
    fi

    if [[ "$EXISTING_WEBSERVER" == "none" ]]; then
        print_error "No web server detected"
        sleep 2
        main_menu
        return
    fi

    setup_ssl "$domain" "$EXISTING_WEBSERVER"

    echo ""
    read -p "Press Enter to continue..."
    main_menu
}

#############################################################################
# Start Script
#############################################################################

# Check if running with sudo/root for system operations
if [[ $EUID -eq 0 ]]; then
    print_warning "Running as root. This is OK, but not required."
    echo ""
fi

# Run main menu
main_menu

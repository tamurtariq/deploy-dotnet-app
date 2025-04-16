#!/bin/bash

set -e

# Input values
read -p "Enter the project name: " PROJECT_NAME
read -p "Enter the domain name (e.g., example.com): " DOMAIN_NAME
read -p "Enter the Git repo URL (leave blank to create a sample app): " GIT_REPO

APP_DIR="/var/www/$PROJECT_NAME"
PUBLISH_DIR="$APP_DIR/publish"
PORT=5000

# Install dependencies if not already installed
install_if_missing() {
    if ! command -v $1 &>/dev/null; then
        echo "Installing $1..."
        sudo apt update
        sudo apt install -y $2
    fi
}

install_if_missing dotnet "dotnet-sdk-8.0"
install_if_missing nginx nginx
install_if_missing git git

# Create app directory
sudo mkdir -p "$APP_DIR"
sudo chown $USER:$USER "$APP_DIR"

# Clone or create app
if [[ -n "$GIT_REPO" ]]; then
    git clone "$GIT_REPO" "$APP_DIR"
else
    dotnet new webapp -o "$APP_DIR"
    echo "<h1>Hello from $PROJECT_NAME!</h1>" > "$APP_DIR/Pages/Index.cshtml"
fi

# Publish the app
dotnet publish "$APP_DIR" -c Release -o "$PUBLISH_DIR" --urls "http://0.0.0.0:$PORT"

# Create systemd service
SERVICE_FILE="/etc/systemd/system/$PROJECT_NAME.service"
sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=$PROJECT_NAME .NET App
After=network.target

[Service]
WorkingDirectory=$PUBLISH_DIR
ExecStart=/usr/bin/dotnet $PUBLISH_DIR/$(basename $APP_DIR).dll
Restart=always
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=$PROJECT_NAME
User=www-data
Environment=ASPNETCORE_URLS=http://0.0.0.0:$PORT
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start the app
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable $PROJECT_NAME
sudo systemctl start $PROJECT_NAME

# Set up Nginx config
NGINX_CONF="/etc/nginx/sites-available/$PROJECT_NAME"
sudo bash -c "cat > $NGINX_CONF" <<EOF
server {
    listen 80;
    server_name $DOMAIN_NAME;

    location / {
        proxy_pass         http://127.0.0.1:$PORT;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade \$http_upgrade;
        proxy_set_header   Connection keep-alive;
        proxy_set_header   Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
    }

    # Uncomment the lines below when SSL certs are ready
    #
    # listen 443 ssl;
    # ssl_certificate     /etc/ssl/certs/$PROJECT_NAME.crt;
    # ssl_certificate_key /etc/ssl/private/$PROJECT_NAME.key;
    #
    # include snippets/ssl-params.conf;
}
EOF

sudo ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# Final Instructions
echo -e "\n🎉 Deployment Complete!"
echo "Your app is live at: http://$DOMAIN_NAME/"
echo "➡️ To enable HTTPS:"
echo "1. Place your SSL certificate at: /etc/ssl/certs/$PROJECT_NAME.crt"
echo "2. Place your private key at: /etc/ssl/private/$PROJECT_NAME.key"
echo "3. Uncomment the SSL lines in $NGINX_CONF"
echo "4. Then run: sudo nginx -t && sudo systemctl reload nginx"

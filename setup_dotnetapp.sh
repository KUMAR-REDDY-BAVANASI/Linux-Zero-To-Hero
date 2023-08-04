#!/bin/bash

# Install prerequisites
sudo apt-get update && \
  sudo apt-get install -y unzip

# Install .NET SDK and runtime
sudo wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo rm -fr packages-microsoft-prod.deb

sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-7.0

sudo apt-get update && \
  sudo apt-get install -y aspnetcore-runtime-6.0

# Display installed .NET SDKs and runtimes
dotnet --list-sdks
dotnet --list-runtimes

# Upgrade system packages
sudo apt update && sudo apt upgrade -y

# Install Node.js and Angular CLI
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g @angular/cli

# Check Node.js and npm versions
node -v
npm -v

# Create directory for myapp deployment if it does not exist
if [ ! -d /var/www/myapp-deploy ]; then
    sudo mkdir -p /var/www/myapp-deploy
    sudo chown $USER /var/www/myapp-deploy/
    sudo chmod u+w /var/www/myapp-deploy/
fi

# Install Nginx
sudo apt update -y
sudo apt install nginx -y

# Create Nginx default configuration if it does not exist
if [ ! -f /etc/nginx/sites-available/default.conf ]; then
    sudo tee /etc/nginx/sites-available/default.conf <<EOF
server {
    listen        80;
    server_name   localhost;
    location / {
        proxy_pass         http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade \$http_upgrade;
        proxy_set_header   Connection keep-alive;
        proxy_set_header   Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
    }
}
EOF
fi

# Create a symbolic link for the Nginx configuration
sudo ln -sf /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/

# Test Nginx configuration
sudo rm -fr /etc/nginx/sites-enabled/default
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

# Check if kestrel-myapp.service exists before creating it
if [ ! -f /etc/systemd/system/kestrel-myapp.service ]; then
    sudo tee /etc/systemd/system/kestrel-myapp.service <<EOF
[Unit]
Description=myapp .NET Web API App running on Linux
Wants=network-online.target
After=network-online.target

[Service]
WorkingDirectory=/var/www/myapp-deploy
ExecStart=/usr/bin/dotnet oft.myapp.web.dll
Restart=always
# Restart service after 10 seconds if the dotnet service crashes:
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=dotnet-example
User=www-data
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false

[Install]
WantedBy=multi-user.target
EOF
fi

# Reload the systemd manager configuration
sudo systemctl daemon-reload

# Enable and start the Kestrel service
sudo systemctl enable kestrel-myapp.service
sudo systemctl start kestrel-myapp.service

# Check the status of the Kestrel service
sudo systemctl status kestrel-myapp.service

# View the logs for the Kestrel service
# sudo journalctl -fu kestrel-myapp.service
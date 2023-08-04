#!/bin/bash

# Install prerequisites
sudo apt-get update && \
  sudo apt upgrade -y && \
  sudo apt-get install -y unzip 

# Install .NET SDK and runtime
sudo wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo rm -fr packages-microsoft-prod.deb

sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-7.0

# Install .NET Core runtime version 3.1
sudo apt install -y aspnetcore-runtime-3.1

# Install Node Version Manager (nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

# Reload the shell to start using nvm
source ~/.bashrc

# Install Node.js 16.x
nvm install 16

# Use Node.js 16.x globally
nvm use 16

# Install Angular CLI v8.3.14
npm install -g @angular/cli@8.3.14

# Install @angular-devkit/build-angular@0.803.24
npm install --save-dev @angular-devkit/build-angular@0.803.24

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
ExecStart=/usr/bin/dotnet ZCG_Site.dll
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
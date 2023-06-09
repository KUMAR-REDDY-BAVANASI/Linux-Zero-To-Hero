Reverse proxy Nginx
-------------------
```
sudo apt update
```

```
sudo apt install nginx
```

```
sudo vi /etc/nginx/sites-available/myapp.conf
```

```
server {
    listen 80;
    server_name your_domain_or_ip;

    location / {
        proxy_pass http://localhost:your_app_port;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Example:
--------
```
server {
    listen 80;
    server_name your_domain_or_ip;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```
sudo ln -s /etc/nginx/sites-available/myapp.conf /etc/nginx/sites-enabled/
```

```
sudo nginx -t
```

```
sudo systemctl restart nginx
```

After reverse proxy we need to create a service for dotnet core application
----------------------------------------------------------------------------
```
sudo vi /etc/systemd/system/myapp.service
```

```
[Unit]
Description=Your App Name
Wants=network-online.target
After=network-online.target

[Service]
WorkingDirectory=/path/to/YourAppPath
ExecStart=/usr/bin/dotnet run
Restart=always
# Uncomment the line below if your application requires environment variables
# Environment=ASPNETCORE_ENVIRONMENT=Production

[Install]
WantedBy=multi-user.target
```

Example:
--------
```
[Unit]
Description=Dataroom
Wants=network-online.target
After=network-online.target

[Service]
WorkingDirectory=/home/ubuntu/olympuse-DR/out
ExecStart=dotnet oft.dataroom.web.dll
Restart=always
# Uncomment the line below if your application requires environment variables
# Environment=ASPNETCORE_ENVIRONMENT=Production

[Install]
WantedBy=multi-user.target
```

```
sudo systemctl enable myapp.service
```

```
sudo systemctl start myapp.service
```

```
sudo systemctl status myapp.service
```

```
sudo systemctl stop myapp.service
```

```
sudo systemctl restart myapp.service
```

```
sudo journalctl -u myapp.service
```

Examine Nginx Error Logs
-------------------------
```
sudo tail -f /var/log/nginx/error.log
```

Remove Nginx in server completely
---------------------------------
```
sudo systemctl stop nginx
```

```
sudo apt purge nginx
```

```
sudo apt purge nginx-common
```

```
sudo rm -rf /etc/nginx
```

```
sudo deluser --remove-home nginx
```

```
sudo delgroup nginx
```
Reverse proxy Apache2 Ubuntu 20.04
----------------------------------
```
sudo apt update
```

```
sudo apt install apache2
```

```
sudo a2enmod proxy
```

```
sudo a2enmod proxy_http
```

```
sudo vi /etc/apache2/sites-available/myapp.conf
```

```
<VirtualHost *:80>
    ServerName your_domain_or_ip

    ProxyPreserveHost On
    ProxyPass / http://localhost:your_app_port/
    ProxyPassReverse / http://localhost:your_app_port/
</VirtualHost>
```

Example
-------
```
<VirtualHost *:80>
    ServerName localhost

    ProxyPreserveHost On
    ProxyPass / http://localhost:5000/
    ProxyPassReverse / http://localhost:5000/
</VirtualHost>
```

```
sudo a2ensite myapp.conf
```

```
sudo systemctl restart apache2
```

After reverse proxy we need to create a service for dotnet core application
----------------------------------------------------------------------------
sudo vi /etc/systemd/system/myapp.service

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


Examine Apache2 Error Logs
--------------------------
```
sudo tail -f /var/log/apache2/error.log
```

Remove apache2 from ubuntu
----------------------------
```
sudo systemctl stop apache2
```

```
sudo systemctl disable apache2
```

```
sudo apt purge apache2 apache2-bin apache2-utils
```

```
sudo rm -rf /etc/apache2
```

```
sudo deluser --remove-home www-data
```

```
sudo delgroup www-data
```
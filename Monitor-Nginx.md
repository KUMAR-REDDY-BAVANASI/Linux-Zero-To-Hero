How to Monitor Nginx with Prometheus and Grafana? (Step-by-Step - Install - Monitor)
------------------------------------------------------------------------------------
Install Dependencies
---------------------

```
sudo apt update
sudo apt install nginx
sudo nginx -v
sudo systemctl enable nginx
sudo systemctl status nginx
sudo systemctl start nginx
sudo systemctl status nginx
```

Expose Basic Nginx Metrics
--------------------------
Let's create a new Nginx configuration file to add an additional server block with our metric module. If you used a different method to install Nginx, for example, default Ubuntu packages, you might have a different location for Nginx configurations.

Before creating a file, let me switch to the root Linux user. Later we will adjust Linux permissions and ownership.

```
sudo -s
```

Now the configuration file.

```
sudo vim /etc/nginx/conf.d/status.conf
```

Optionally you can restrict this plugin to emit metrics to only the local host. It may be useful if you have a single Nginx instance and you install prometheus exporter on it as well. In case you have multiple Nginx servers, it's better to deploy the prometheus exporter on a separate instance and scrape all of them from a single exporter.

We'll use the location Nginx directive to expose basic metrics on port 8080 /status page.

```
server {
    listen 8080;
    # Optionally: allow access only from localhost
    # listen 127.0.0.1:8080;

    server_name _;

    location /status {
        stub_status;
    }
}
```

Always verify if the configuration is valid before restarting Nginx.

```
sudo nginx -t
```

To update the Nginx config without downtime, you can use reload command.

```
sudo systemctl reload nginx
```

Now we can access http://<ip>:8080/status page.

```
Active connections: 2 
server accepts handled requests
 4 4 3 
Reading: 0 Writing: 1 Waiting: 1 
```

Unfortunately, Open Source Nginx server only exposes these not-very useful metrics. I guess I would pay attention only to the active connections metric from here.


Install Nginx Prometheus Exporter
---------------------------------
Still, let's fetch all the available metrics for now. We'll use the Nginx prometheus exporter to do that. It's a Golang application that compiles to a single binary without external dependencies, which is very easy to install.

First of all, let's create a folder for the exporter and switch directory.

```
sudo mkdir /opt/nginx-exporter
cd /opt/nginx-exporter
```

As a best practice, you should always create a dedicated user for each application that you want to run. Let's call it an nginx-exporter user and a group.

```
sudo useradd --system --no-create-home --shell /bin/false nginx-exporter
```

From the releases pages on GitHub, let's find the latest version and copy the link to the appropriate archive. In my case, it's a standard amd64 platform.

We can use curl to download the exporter on the Ubuntu machine.

```
sudo curl -L https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v0.11.0/nginx-prometheus-exporter_0.11.0_linux_amd64.tar.gz -o nginx-prometheus-exporter_0.11.0_linux_amd64.tar.gz
```

Extract the prometheus exporter from the archive.

```
sudo tar -zxf nginx-prometheus-exporter_0.11.0_linux_amd64.tar.gz
```

You can also remove it to save some space.

```
sudo rm nginx-prometheus-exporter_0.11.0_linux_amd64.tar.gz
```

Let's make sure that we downloaded the correct binary by checking the version of the exporter.

```
./nginx-prometheus-exporter --version
```

It's optional; let's update the ownership on the exporter folder.

```
sudo chown -R nginx-exporter:nginx-exporter /opt/nginx-exporter
```

To run it, let's also create a systemd service file. In case it exits systemd manager can restart it. It's the standard way to run Linux daemons.

```
sudo vim /etc/systemd/system/nginx-exporter.service
```

Make sure you update the scrape-uri to the one you used in Nginx to expose basic metrics. Also, update the Linux user and the group to match yours in case you used different names.

```
[Unit]
Description=Nginx Exporter
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=0

[Service]
User=nginx-exporter
Group=nginx-exporter
Type=simple
Restart=on-failure
RestartSec=5s

ExecStart=/opt/nginx-exporter/nginx-prometheus-exporter \
    -nginx.scrape-uri=http://localhost:8080/status

[Install]
WantedBy=multi-user.target
```

Enable the service to automatically start the daemon on Linux restart.

```
systemctl enable nginx-exporter
```

Then start the nginx prometheus exporter.

```
systemctl start nginx-exporter
```

Check the status of the service.

```
systemctl status nginx-exporter
```

If your exporter fails to start, you can check logs to find the error message.

```
journalctl -u nginx-exporter -f --no-pager
```

To verify that Prometheus exporter can access nginx and properly scrape metrics, use curl command and default 9113 port for the exporter.

```
curl localhost:9113/metrics
```

Now you should be able to get the same metrics from the status page but in Prometheus format.

```
# HELP nginx_connections_accepted Accepted client connections
# TYPE nginx_connections_accepted counter
nginx_connections_accepted 8
# HELP nginx_connections_active Active client connections
# TYPE nginx_connections_active gauge
nginx_connections_active 1
# HELP nginx_connections_handled Handled client connections
# TYPE nginx_connections_handled counter
nginx_connections_handled 8
# HELP nginx_connections_reading Connections where NGINX is reading the request header
# TYPE nginx_connections_reading gauge
nginx_connections_reading 0
# HELP nginx_connections_waiting Idle client connections
# TYPE nginx_connections_waiting gauge
nginx_connections_waiting 0
# HELP nginx_connections_writing Connections where NGINX is writing the response back to the client
# TYPE nginx_connections_writing gauge
nginx_connections_writing 1
# HELP nginx_http_requests_total Total http requests
# TYPE nginx_http_requests_total counter
nginx_http_requests_total 8
# HELP nginx_up Status of the last metric scrape
# TYPE nginx_up gauge
nginx_up 1
```
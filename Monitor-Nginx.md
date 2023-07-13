How to Monitor Nginx with Prometheus and Grafana? (Step-by-Step - Install - Monitor)
------------------------------------------------------------------------------------
Install Nginx
-------------
To install the latest stable nginx version, we need to add an official nginx repository. First of all, before installing Nginx itself, we need to install some prerequisites.

```
sudo apt update
sudo apt install curl gnupg2 ca-certificates lsb-release ubuntu-keyring
```

Import an official nginx signing key so apt could verify the packages authenticity.

```
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
```

Verify that the downloaded file contains the proper key. If the fingerprint is different, remove the file.

```
gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg
```

To set up the apt repository for stable nginx packages, run the following command:

```
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
```

To install nginx, run the following commands:

```
sudo apt update
apt-cache policy nginx
sudo apt install nginx
```

Let's make sure that the basic metric module is configured with the nginx.

```
sudo nginx -V
```

You should be able to find --with-http_stub_status_module in the output. If you don't have it, you need to compile Nginx with this module or use the dynamic modules.

Let's check if the Nginx is running.

```
sudo systemctl status nginx
```

In case it's not, let's start it.

```
sudo systemctl start nginx
sudo systemctl enable nginx
```

Now it should be in a running state.

```
sudo systemctl status nginx
```

Let's use the Ubuntu IP address (http://<ip>/) to check if we can access Nginx.


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


Install Prometheus
-------------------
Now let's quickly install the latest version of prometheus on the same host.

Create a dedicated Linux user for Prometehus.

```
sudo useradd --system --no-create-home --shell /bin/false prometheus
```

Let's check the latest version of Prometheus from the download page.

You can use the curl or wget command to download Prometheus.

```
sudo curl -L https://github.com/prometheus/prometheus/releases/download/v2.41.0/prometheus-2.41.0.linux-amd64.tar.gz -o prometheus-2.41.0.linux-amd64.tar.gz
```

Then, we need to extract all Prometheus files from the archive.

```
sudo tar -xvf prometheus-2.41.0.linux-amd64.tar.gz
```

Usually, you would have a disk mounted to the data directory. For this tutorial, I will simply create a /data director. Also, you need a folder for Prometheus configuration files.

```
sudo mkdir -p /data /etc/prometheus
```
Now, let's change the directory to Prometheus and move some files.

```
cd prometheus-2.41.0.linux-amd64
```

First of all, let's move the prometheus binary and a promtool to the /usr/local/bin/. promtool is used to check configuration files and Prometheus rules.

```
sudo mv prometheus promtool /usr/local/bin/
```

Optionally, we can move console libraries to the Prometheus configuration directory. Console templates allow for the creation of arbitrary consoles using the Go templating language. You don't need to worry about it if you're just getting started.

```
sudo mv consoles/ console_libraries/ /etc/prometheus/
```

Finally, let's move the example of the main prometheus configuration file.

```
sudo mv prometheus.yml /etc/prometheus/prometheus.yml
```
To avoid permission issues, you need to set correct ownership for the /etc/prometheus/ and /data directory.

```
sudo chown -R prometheus:prometheus /etc/prometheus/ /data/
```

Optionally you can clean up and delete the archive itself and unused files.

Verify that you can execute the Prometheus binary by running the following command:

```
sudo prometheus --version
```

We're going to use systemd, which is a system and service manager for Linux operating systems. For that, we need to create a systemd unit configuration file.

```
sudo vim /etc/systemd/system/prometheus.service
```

Make sure you're using the correct username and group. Also, check the data path.

```
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=0

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/data \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
```

Before we launch Prometheus, let's add our Nginx Prometheus Exporter as a target.

```
sudo vim /etc/prometheus/prometheus.yml
```

Update the job name to nginx-prometheus-exporter and port to 9113.

```
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "nginx-prometheus-exporter"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9113"]
```

To automatically start the Prometheus after reboot, run enable.

```
sudo systemctl enable prometheus
```

Then just start the Prometheus.

```
sudo systemctl start prometheus
```

To check the status of Prometheus run following command:

```
systemctl status prometheus
```

Now you can go to http://<ip>:9090/ to check if the prometheus is working.

Under the targets section, you should have a single nginx-prometheus-exporter target.

Now, you can query your metrics from the Prometheus explorer tab. For example, you can use nginx_connections_active to get active nginx connections.


Install Grafana
-----------------
The next step is to install Grafana, which is much simpler since we can use official repository.

First, let's make sure that all the dependencies are installed.

```
sudo apt install -y apt-transport-https software-properties-common
```

Next, add GPG key.

```
sudo wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
```

Add this repository for stable releases.

```
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
```

After you add the repository, update and install Garafana.

```
sudo apt update
sudo apt -y install grafana
```

To automatically start the Grafana after reboot, enable the service.

```
sudo systemctl enable grafana-server
```

Then start the Grafana.

```
systemctl start grafana-server
```

To check the status of Grafana, run the following command

```
systemctl status grafana-server
```

Now you can access Grafana on port http://<ip>:3000. The username is admin, and the password is admin as well.

First of all, let's add our Prometheus as a datasource.

For the URL, use http://localhost:9090 and click save and test.

Let's create a new dashboard and call it Nginx.

Create a new Panel.

For the metrics use nginx_connections_active.

For the legend {{ instance }}.

Title: Active Connections.

I'm going to fill out the rest of the panels using the metrics that we retried from the status page. You can find this dashboard in my github repository.

On the left-hand side, we have all the gauges, and on the right-hand side, all the counters. To make use of the counter, you need to apply a rate function, for example, to calculate a number of requests per second.

NGINX exporter Dashboard
------------------------
Go to Dashboards--->Select New--->Click Import--->Give Dashboard ID '12708' and Load --->Select datasource prometheus and import.

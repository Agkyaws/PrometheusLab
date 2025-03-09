#!/bin/bash

# Create Prometheus user
sudo useradd --no-create-home --shell /bin/false prometheus

# Create necessary directories
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

# Set ownership of directories
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

# Download Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.53.3/prometheus-2.53.3.linux-amd64.tar.gz

# Extract the downloaded file
tar xvf prometheus-2.53.3.linux-amd64.tar.gz
cd prometheus-2.53.3.linux-amd64

# Move binaries to the installation directory
sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/

# Set ownership of binaries
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

# Move configuration files
sudo cp -r consoles /etc/prometheus
sudo cp -r console_libraries /etc/prometheus

# Set ownership of configuration files
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries

# Move the existing Prometheus configuration file
sudo cp prometheus.yml /etc/prometheus/prometheus.yml

# Set ownership of the configuration file
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

# Create systemd service file
cat <<EOL | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \\
  --config.file /etc/prometheus/prometheus.yml \\
  --storage.tsdb.path /var/lib/prometheus \\
  --web.console.templates=/etc/prometheus/consoles \\
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd to recognize the new service
sudo systemctl daemon-reload

# Start and enable Prometheus service
sudo systemctl start prometheus
sudo systemctl enable prometheus

# Check the status of Prometheus service
sudo systemctl status prometheus

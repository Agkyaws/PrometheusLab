#!/bin/bash

# Variables
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/prometheus"
DATA_DIR="/var/lib/prometheus"
USER="prometheus"

# Update the package index
echo "Updating package index..."
apt-get update

# Install necessary packages
echo "Installing necessary packages..."
apt-get install -y wget tar jq

# Fetch the latest version of Prometheus
echo "Fetching the latest version of Prometheus..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | jq -r .tag_name | sed 's/v//')

# Create a user and group for Prometheus
echo "Creating Prometheus user and group..."
useradd --no-create-home --shell /bin/false $USER

# Create directories
echo "Creating directories..."
mkdir -p $CONFIG_DIR
mkdir -p $DATA_DIR
chown $USER:$USER $DATA_DIR

# Download Prometheus
echo "Downloading Prometheus version $LATEST_VERSION..."
wget https://github.com/prometheus/prometheus/releases/download/v$LATEST_VERSION/prometheus-$LATEST_VERSION.linux-amd64.tar.gz

# Extract the downloaded file
echo "Extracting Prometheus..."
tar xvf prometheus-$LATEST_VERSION.linux-amd64.tar.gz

# Move binaries to the installation directory
echo "Moving binaries..."
mv prometheus-$LATEST_VERSION.linux-amd64/prometheus $INSTALL_DIR/
mv prometheus-$LATEST_VERSION.linux-amd64/promtool $INSTALL_DIR/

# Move configuration files
echo "Moving configuration files..."
mv prometheus-$LATEST_VERSION.linux-amd64/consoles $CONFIG_DIR/
mv prometheus-$LATEST_VERSION.linux-amd64/console_libraries $CONFIG_DIR/

# Create a Prometheus configuration file
cat <<EOL > $CONFIG_DIR/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOL

# Set ownership
chown -R $USER:$USER $CONFIG_DIR
chown $USER:$USER $INSTALL_DIR/prometheus
chown $USER:$USER $INSTALL_DIR/promtool

# Create a systemd service file
cat <<EOL > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$USER
Type=simple
ExecStart=$INSTALL_DIR/prometheus --config.file=$CONFIG_DIR/prometheus.yml --storage.tsdb.path=$DATA_DIR

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd to recognize the new service
echo "Reloading systemd..."
systemctl daemon-reload

# Start and enable Prometheus service
echo "Starting and enabling Prometheus service..."
systemctl start prometheus
systemctl enable prometheus

# Clean up
echo "Cleaning up..."
rm -rf prometheus-$LATEST_VERSION.linux-amd64*
echo "Prometheus installation and setup complete!"

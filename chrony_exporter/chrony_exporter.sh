#!/bin/bash

# Set Chrony Exporter version
CHRONY_EXPORTER_VERSION="0.12.1"

# Download and extract Chrony exporter
wget https://github.com/SuperQ/chrony_exporter/releases/download/v${CHRONY_EXPORTER_VERSION}/chrony_exporter-${CHRONY_EXPORTER_VERSION}.linux-amd64.tar.gz
tar -xzvf chrony_exporter-${CHRONY_EXPORTER_VERSION}.linux-amd64.tar.gz
cd chrony_exporter-${CHRONY_EXPORTER_VERSION}.linux-amd64
cp chrony_exporter /usr/local/bin/

# Create user for chrony_exporter
useradd --no-create-home --shell /bin/false chrony_exporter

# Set ownership
chown chrony_exporter:chrony_exporter /usr/local/bin/chrony_exporter

# Create systemd service
echo '[Unit]
Description=Chrony Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=chrony_exporter
Group=chrony_exporter
Type=simple
ExecStart=/usr/local/bin/chrony_exporter

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/chrony_exporter.service

# Enable and start service
systemctl daemon-reload
systemctl start chrony_exporter
systemctl enable chrony_exporter

echo "Chrony Exporter setup complete.
Add the following lines to /etc/prometheus/prometheus.yml:

  - job_name: 'chrony_exporter'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9116']   # Default port of chrony_exporter
"

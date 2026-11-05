#!/bin/bash -e
# Hobby Ticker OS installation stage
echo "=== Setting up Hobby Ticker OS ==="

# Install required packages
apt-get update
apt-get install -y build-essential git curl avahi-daemon network-manager openssl python3 python3-venv python3-pip python3-dev python3-setuptools cython3 libcap2-bin libffi-dev libopenjp2-7 libopenblas0 libjpeg62-turbo libtiff6 libxcb1

# Create installer directory
mkdir -p /opt/hobbyticker-installer

# Copy first-boot install script
install -m 755 ../files/first-boot-install.sh /opt/hobbyticker-installer/

# Copy and enable systemd service
install -m 644 ../files/hobbyticker-first-boot-install.service /etc/systemd/system/
systemctl enable hobbyticker-first-boot-install.service

echo "=== Hobby Ticker OS setup completed ==="
echo "Installation will run on first boot"
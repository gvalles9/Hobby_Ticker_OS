#!/bin/bash -e
# Install systemd service for Hobby Ticker

echo "Installing systemd service..."

# Copy service file
cp /home/pi/FlightTracker/assets/FlightTracker.service /etc/systemd/system/FlightTracker.service

# Enable service
systemctl enable FlightTracker.service

echo "Systemd service installed and enabled"

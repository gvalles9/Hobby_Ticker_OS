#!/bin/bash -e
# Install Hobby Ticker dependencies and set up virtual environment

echo "Setting up Python virtual environment and dependencies..."

cd /home/pi/FlightTracker

# Create virtual environment
python3 -m venv env

# Activate and install dependencies
./env/bin/pip install --upgrade pip
./env/bin/pip install -r platforms/pi5/requirements.txt

# Set ownership
chown -R pi:pi /home/pi/FlightTracker

echo "Dependencies installed successfully"

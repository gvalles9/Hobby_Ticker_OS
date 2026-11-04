#!/bin/bash -e
# Clone Hobby Ticker repository and set up the installation

echo "Installing Hobby Ticker..."

# Create FlightTracker directory
mkdir -p /home/pi/FlightTracker

# Clone the repository
git clone https://github.com/gvalles9/Hobby_Ticker_Wall.git /home/pi/FlightTracker

# Set ownership
chown -R pi:pi /home/pi/FlightTracker

echo "Hobby Ticker cloned successfully"

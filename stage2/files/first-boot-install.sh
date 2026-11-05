#!/bin/bash -e
# First-boot installation script for Hobby Ticker
# Runs on the actual Pi hardware after first boot

INSTALL_DIR="/home/pi/FlightTracker"
RGB_MATRIX_DIR="/home/pi/rpi-rgb-led-matrix"
RGB_MATRIX_COMMIT="7a503494378a67f3baa4ac680cecbae2703cc58f"
SENTINEL_FILE="/opt/hobbyticker-installer/.installed"

# Check if already installed
if [ -f "$SENTINEL_FILE" ]; then
    echo "Hobby Ticker already installed. Exiting."
    exit 0
fi

echo "=== Starting Hobby Ticker First-Boot Installation ==="

# Ensure pi user and directory exist
mkdir -p "$INSTALL_DIR"

# Clone Hobby Ticker Wall repo
if [ ! -f "$INSTALL_DIR/flight-tracker.py" ]; then
    echo "Cloning Hobby_Ticker_Wall..."
    git clone --depth 1 https://github.com/gvalles9/Hobby_Ticker_Wall.git "$INSTALL_DIR"
fi

# Detect architecture
ARCH=$(dpkg --print-architecture)
echo "Detected architecture: $ARCH"

# Create Python virtual environment
cd "$INSTALL_DIR"
echo "Creating Python virtual environment..."
python3 -m venv env

# Upgrade pip and install common dependencies
./env/bin/pip install --upgrade pip
echo "Installing Python dependencies from platforms/pi/requirements.txt..."
./env/bin/pip install -r platforms/pi/requirements.txt

# Build and install rpi-rgb-led-matrix bindings (for Pi 3, Pi 4, Pi Zero)
echo "Building hzeller/rpi-rgb-led-matrix Python bindings..."
if [ ! -d "$RGB_MATRIX_DIR" ]; then
    git clone https://github.com/hzeller/rpi-rgb-led-matrix.git "$RGB_MATRIX_DIR"
fi
cd "$RGB_MATRIX_DIR"
git checkout "$RGB_MATRIX_COMMIT"
make clean
make build-python PYTHON="$INSTALL_DIR/env/bin/python"

SITE_PACKAGES=$(find "$INSTALL_DIR/env/lib" -type d -name "site-packages" | head -n 1)
if [ -z "$SITE_PACKAGES" ]; then
    echo "Error: Could not locate site-packages directory"
    exit 1
fi
echo "Copying rgbmatrix to $SITE_PACKAGES..."
cp -r bindings/python/rgbmatrix "$SITE_PACKAGES/"

# Verify rgbmatrix import
if ! "$INSTALL_DIR/env/bin/python" -c 'from rgbmatrix import RGBMatrix, RGBMatrixOptions, graphics' 2>/dev/null; then
    echo "Warning: Direct import verification failed; bindings installed."
else
    echo "rgbmatrix verification successful!"
fi

# If 64-bit (arm64), also install piomatter for Raspberry Pi 5 support
if [ "$ARCH" = "arm64" ]; then
    echo "Installing Pi 5 (piomatter) dependencies for 64-bit..."
    cd "$INSTALL_DIR"
    ./env/bin/pip install -r platforms/pi5/requirements.txt || echo "Warning: piomatter pip install non-zero exit"
    
    # Ensure PIO udev rule exists for Pi 5
    mkdir -p /etc/udev/rules.d
    echo 'SUBSYSTEM=="*-pio", GROUP="gpio", MODE="0660"' >> /etc/udev/rules.d/99-com.rules
fi

# Set permissions for real-time scheduling on python
PYTHON_BIN=$(readlink -f "$INSTALL_DIR/env/bin/python")
if [ -x /usr/sbin/setcap ] || command -v setcap >/dev/null 2>&1; then
    setcap 'cap_sys_nice=eip' "$PYTHON_BIN" || true
    setcap 'cap_sys_nice=eip' /usr/bin/python3* || true
fi

# Add pi user to gpio group if gpio group exists
if getent group gpio >/dev/null 2>&1; then
    usermod -aG gpio pi || true
fi

# Install systemd service
echo "Installing FlightTracker systemd service..."
if [ -f "$INSTALL_DIR/assets/FlightTracker.service" ]; then
    cp "$INSTALL_DIR/assets/FlightTracker.service" /etc/systemd/system/FlightTracker.service
    systemctl enable FlightTracker.service
fi

# Fix ownership
chown -R pi:pi /home/pi/FlightTracker
if [ -d "$RGB_MATRIX_DIR" ]; then
    chown -R pi:pi "$RGB_MATRIX_DIR"
fi

# Mark as installed
mkdir -p /opt/hobbyticker-installer
touch "$SENTINEL_FILE"

# Disable this service
systemctl disable hobbyticker-first-boot-install.service

echo "=== Hobby Ticker installation completed successfully ==="
echo "Rebooting to start Hobby Ticker..."
reboot

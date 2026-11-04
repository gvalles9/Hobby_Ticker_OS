# Hobby Ticker OS

Hobby Ticker OS is a prebuilt Raspberry Pi OS image with Hobby Ticker pre-installed. Based on Colin Waddell's FlightTracker project, it includes RGB matrix drivers, Python dependencies, and web-based configuration. Supports Raspberry Pi 3, 4, and 5.

## Features

- Pre-installed Hobby Ticker application
- RGB matrix drivers (hzeller rgbmatrix for Pi 3/4, Adafruit piomatter for Pi 5)
- Web-based configuration interface
- First-boot Wi-Fi setup hotspot
- No command line required

## Installation

### Using Raspberry Pi Imager (Recommended)

1. Download and install [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
2. Open Imager and go to **App Options → Content Repository → Custom URL**
3. Enter: `https://raw.githubusercontent.com/gvalles9/Hobby_Ticker_OS/main/os_list.json`
4. Select "Hobby Ticker OS" from the OS list
5. Choose the version for your Pi:
   - **32-bit** for Raspberry Pi 3
   - **64-bit** for Raspberry Pi 4/5
6. Set your Wi-Fi details and hostname (e.g., `hobbyticker`)
7. Flash to SD card
8. Boot your Pi and open `http://hobbyticker.local:8584` in your browser

### Manual Download

Download the image from the [Releases](https://github.com/gvalles9/Hobby_Ticker_OS/releases) page and flash with Raspberry Pi Imager or balenaEtcher.

## Hardware Requirements

- Raspberry Pi 3, 4, or 5
- Adafruit RGB Matrix Bonnet or HAT
- 64x32 RGB LED matrix panel(s) (three panels chained horizontally for standard 192x32 layout)
- MicroSD card (8GB minimum, Class 10 recommended)
- 5V power supply (3A+ recommended)

## Configuration

After first boot, access the web interface at:
- `http://hobbyticker.local:8584` (if mDNS is working)
- `http://<your-pi-ip>:8584` (check your router for the IP)

The web interface allows you to configure:
- Location (with map)
- Flight filters
- Airport display
- Weather settings
- Display theme and brightness
- Satellite tracking
- Hardware options

## Building the Image

### Local Build (for testing)

Requires a Debian-based system with Docker:

```bash
git clone https://github.com/RPi-Distro/pi-gen.git --branch master --depth 1
cd pi-gen
git clone https://github.com/gvalles9/Hobby_Ticker_OS.git custom-stages
cp -r custom-stages/stage2-hobbyticker .
cp custom-stages/config config
./build-docker.sh
```

The built image will be in `deploy/`.

### Automated Builds

Images are built automatically on GitHub Actions on:
- Push to `main` branch
- Manual workflow dispatch
- Weekly (Monday 2:00 AM UTC) to keep base OS updated

## Credits

- **Original FlightTracker**: [Colin Waddell](https://github.com/ColinWaddell/FlightTracker)
- **pi-gen**: [Raspberry Pi Foundation](https://github.com/RPi-Distro/pi-gen)
- **pi-gen-action**: [usimd](https://github.com/usimd/pi-gen-action)

## License

This image build infrastructure is licensed under the same terms as Hobby Ticker. The base Raspberry Pi OS is licensed by the Raspberry Pi Foundation.
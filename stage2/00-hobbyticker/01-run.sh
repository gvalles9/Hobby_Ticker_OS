#!/bin/bash -e
# Hobby Ticker OS stage.
#
# NOTE: a "-run.sh" script executes on the pi-gen *build host* with the image
# filesystem available at ${ROOTFS_DIR}. Anything that must happen inside the
# image has to go through on_chroot(). (A "-run-chroot.sh" script would run
# inside the image, but then host-relative file paths like ../files would not
# resolve, so we do the file copying from here instead.)
#
# A previous version of this file did `apt-get install`, `mkdir /opt/...` and
# `install` directly, which silently modified the build container instead of
# the image. That produced a "Hobby Ticker" image that was really plain
# Raspberry Pi OS with no first-boot installer.

echo "=== Setting up Hobby Ticker OS ==="

APT_PACKAGES="
build-essential
git
curl
avahi-daemon
network-manager
openssl
python3
python3-venv
python3-pip
python3-dev
python3-setuptools
cython3
libcap2-bin
libffi-dev
libopenjp2-7
libopenblas0
libjpeg62-turbo
libtiff6
libxcb1
"

# Install build/runtime dependencies inside the image.
on_chroot << EOF
apt-get update
apt-get -o Acquire::Retries=3 install -y ${APT_PACKAGES}
EOF

# Copy the first-boot installer into the image.
install -d "${ROOTFS_DIR}/opt/hobbyticker-installer"
install -m 755 ../files/first-boot-install.sh \
    "${ROOTFS_DIR}/opt/hobbyticker-installer/first-boot-install.sh"
install -m 644 ../files/hobbyticker-first-boot-install.service \
    "${ROOTFS_DIR}/etc/systemd/system/hobbyticker-first-boot-install.service"

# Enable the installer inside the image.
on_chroot << 'EOF'
systemctl enable hobbyticker-first-boot-install.service
EOF

# Fail the build loudly if the image does not actually contain the installer.
# Without these checks a broken image can be uploaded and flashed, which looks
# exactly like "the Pi is running the wrong OS".
test -f "${ROOTFS_DIR}/opt/hobbyticker-installer/first-boot-install.sh"
test -f "${ROOTFS_DIR}/etc/systemd/system/hobbyticker-first-boot-install.service"
test -L "${ROOTFS_DIR}/etc/systemd/system/multi-user.target.wants/hobbyticker-first-boot-install.service"

echo "=== Hobby Ticker OS setup completed ==="
echo "Installation will run on first boot"

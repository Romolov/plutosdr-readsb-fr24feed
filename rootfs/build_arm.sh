#!/bin/bash
set -euo pipefail

# Disable pacman sandbox features not supported in qemu chroot on CI
sed -i 's/^DownloadUser/#DownloadUser/' /etc/pacman.conf

pacman-key --init
pacman-key --populate archlinuxarm

pacman -Syu --noconfirm
pacman --noconfirm -S htop screen ntp wget libiio libad9361 base-devel neofetch git dhclient

git clone "https://github.com/wiedehopf/readsb" /opt/readsb

cd /opt/readsb
make PLUTOSDR=yes -j$(nproc)

cd /opt
FR24FEED_VERSION=$(cat /FR24FEED_VERSION)
wget "https://repo-feed.flightradar24.com/rpi_binaries/fr24feed_${FR24FEED_VERSION}_armhf.tgz"
tar xfvz "fr24feed_${FR24FEED_VERSION}_armhf.tgz"

ln -s /mnt/fr24feed.ini /etc/fr24feed.ini

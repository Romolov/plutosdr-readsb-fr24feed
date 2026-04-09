# PlutoSDR standalone ADS-B FR24 feeder

Fork of [Manawyrm/plutosdr-readsb-fr24feed](https://github.com/Manawyrm/plutosdr-readsb-fr24feed) with automated fr24feed version bumping.

This project turns the PlutoSDR into an inexpensive, very high performance standalone ADS-B receiver and flightradar24 feeder.  
It can be directly connected to the internet via a USB->Ethernet dongle.

The fr24feed application as well as the readsb application runs on Arch Linux ARM:
![https://screenshot.tbspace.de/eapbuojdngt.png](https://screenshot.tbspace.de/eapbuojdngt.png)

### Automated fr24feed version tracking

This fork includes a GitHub Actions workflow that checks the [Flightradar24 APT repository](https://repo-feed.flightradar24.com) daily for new fr24feed releases. When a new version is detected and the corresponding `.tgz` binary is available, the workflow automatically bumps the version in `FR24FEED_VERSION`, pushes to `main`, and triggers a new image build and release.

The current fr24feed version used in builds is tracked in the [`FR24FEED_VERSION`](FR24FEED_VERSION) file.

### Checking the status
You can check the status of the fr24feeder by visiting  
http://192.168.2.183:8754/  (replace with your PlutoSDR's IPv4 address)  
or (if your computer has working mDNS/Avahi name resolution)  
http://pluto.local:8754/

### Hardware requirements
- PlutoSDR
- USB thumb drive, **minimum 5GiB size** (USB SSD, USB SD card reader, etc. is also fine)
- USB ethernet adapter
- USB hub (also available with built-in ethernet adapter)
- microUSB-OTG adapter (included with the PlutoSDR)
- 5V microUSB power supply (Raspberry Pi 3 supplies are recommended)
- ADS-B 1090 MHz antenna
- highly recommended: 1090 MHz band-pass filter

### Installing plutosdr-readsb-fr24feed
- Download the latest release from the [Releases page](../../releases)
- Flash the usb.img.gz to a USB flash drive using [balenaEtcher](https://www.balena.io/etcher/) or dd (remember to un-gzip when using dd). Same as flashing the image for a Raspberry Pi. Warning: This completely erases all data stored on the USB drive.
- Replug the USB device to let your computer recognize the new partitions
- Mount/Open the FAT32 partition and edit the "fr24feed.ini" config file and add your FR24 sharing key.
- Plug the USB drive and USB ethernet adapter into the USB hub, connect to the PlutoSDR and connect the power supply.

### Opening a shell to the ArchLinux ARM system
Run `/media/sd*/shell.sh` via SSH.

### Security
**The PlutoSDR still offers an open SSH server with credentials root / analog when running this image.**  
Please refer to [Analog Devices Wiki - Changing the root password on the target](https://wiki.analog.com/university/tools/pluto/users/customizing#changing_the_root_password_on_the_target) for information on how to setup persistent storage, SSH keys and a different root password.

TCP port 30005 is also open and supplies raw "BEAST" ADS-B data.

### Building image
Building this image is done using qemu-user-static (by running the ArchLinux ARM image in user/static emulation) and does quite a bit of modifications to your system (installing packages, changing binfmt settings, putting stuff in /opt, etc.).

__Please don't run this on your computer! Use a VM, Docker, GitHub Actions, etc.__

#### Using GitHub Actions CI:
Look at [.github/workflows/usb.yaml](.github/workflows/usb.yaml), fork this repository, make your changes and let the CI build a new image for you automatically. Every push to `main` triggers a build, and a GitHub release is created automatically with the resulting `usb.img.gz`.

#### Using docker:  
This uses loop mounts, chroot, binfmt, etc. and thus needs `--privileged` and a bind-mount for `/dev`.
```bash
docker run --rm -it --privileged -v /dev:/dev --entrypoint bash debian:bookworm-slim

apt update -y
apt install -y git
git clone https://github.com/Romolov/plutosdr-readsb-fr24feed
cd plutosdr-readsb-fr24feed

./build_host.sh
```

### Changes from upstream
- **Automated fr24feed version bumping** via a daily GitHub Actions check against the FR24 APT repository (`check-fr24feed.yml`)
- **fr24feed version externalized** into `FR24FEED_VERSION` instead of being hardcoded in `build_arm.sh`
- **Build fixes for Ubuntu 24.04 runners**: replaced `qemu` package with `qemu-system-arm`, disabled pacman Landlock sandboxing for chroot compatibility, replaced removed `neofetch` with `fastfetch`
- **Updated fr24feed** from 1.0.34-0 to the latest available version

### Known issues
#### Manual network setup
Currently not possible, the PlutoSDR uses DHCP to get IP connectivity.

#### Missing IPv6 (and broken connectivity on NAT64 networks)
The PlutoSDR kernel was built without any IPv6 support enabled.  
Not much we can do here without recompiling the kernel.

#### Unable to create Avahi DNS-SD client
readsb outputs  
`ERROR: Unable to create Avahi DNS-SD client :Daemon not running`
at startup.  
libiio tries to initialize Avahi to connect to remote libiio-devices via mDNS.
This project is just connecting to localhost / libiio-URI "local:", so **this is perfectly fine.**

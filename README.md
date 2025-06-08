# Guide how to install FaceTimeHD Driver for Macbook Pro 2015 on Ubuntu 22.04 or later

This guide provides step-by-step instructions to install the FaceTimeHD driver for MacBook webcams on Linux (Debian/Ubuntu). 
<br/>The process includes installing prerequisites, extracting firmware, and building/installing the driver using two methods.

## To get full source code without use many times git clone as below 

Please clone this repo here and don't forget skip some step, then move to **Copy Firmware**

`cd ~; git clone https://github.com/cobaohieu/facetimehd.git`

## Prerequisites

Install the necessary software packages before proceeding.

| Package              | Command                                      |
|----------------------|----------------------------------------------|
| GCC 12               | <code>sudo apt install -y gcc-12</code>      |
| Utilities            | <code>sudo apt install -y xz-utils curl cpio make dwarves</code> |
| Kernel Headers       | <code>sudo apt install -y linux-headers-generic git kmod libssl-dev checkinstall</code> |
| Build Tools          | <code>sudo apt install -y debhelper dkms</code> |
| MPlayer              | <code>sudo apt install -y mplayer</code>     |

## Firmware Extraction

Extract the sensor calibration files and firmware for the FaceTimeHD driver.

| Step | Command/Description |
|------|--------------------|
| **Clone Repository** | Clone the driver and firmware repositories:<br><code>git clone https://github.com/patjak/facetimehd.git</code><br><code>cd facetimehd/firmware</code><br><code>git clone https://github.com/patjak/facetimehd-firmware.git .</code> |
| **Download BootCamp Package** | Download from [Apple Support](https://support.apple.com/kb/DL1837) or check Windows drivers on [Apple.com](https://www.apple.com).<br>Unzip the package:<br><code>cd ~/Downloads/</code><br><code>unzip bootcamp5.1.5769.zip -d ~/Downloads/bootcamp5.1.5769/</code> |
| **Extract Driver** | Extract `AppleCamera64.exe`:<br><code>unrar x bootcamp5.1.5769/BootCamp/Drivers/Apple/AppleCamera64.exe</code><br>Verify `AppleCamera.sys`:<br><code>ls bootcamp5.1.5769/BootCamp/Drivers/Apple/ \| grep AppleCamera.sys</code> |
| **Extract Firmware Files** | Extract `.dat` files:<br><code>dd bs=1 skip=1663920 count=33060 if=AppleCamera.sys of=9112_01XX.dat</code><br><code>dd bs=1 skip=1644880 count=19040 if=AppleCamera.sys of=1771_01XX.dat</code><br><code>dd bs=1 skip=1606800 count=19040 if=AppleCamera.sys of=1871_01XX.dat</code><br><code>dd bs=1 skip=1625840 count=19040 if=AppleCamera.sys of=1874_01XX.dat</code> |
| **Copy Firmware** | Copy `.dat` files to firmware directory:<br><code>sudo scp *.dat /lib/firmware/facetimehd/</code> |
| **Compile Firmware** | Compile and install firmware ([reference](https://github.com/patjak/facetimehd/wiki/Get-Started#firmware-extraction)):<br><code>cd ~/facetimehd/firmware</code><br><code>sudo make</code><br><code>sudo make install</code> |

> **Note**: For detailed firmware extraction instructions, see [Extracting the Sensor Calibration Files](https://github.com/patjak/facetimehd/wiki/Extracting-the-sensor-calibration-files).

## Method 1: Debian

Build and install the kernel module for Debian ([More detail click here](https://github.com/patjak/facetimehd/wiki/Installation#get-started-on-debian)).

| Step | Command/Description |
|------|--------------------|
| **Build Kernel Module** | <code>cd ~/facetimehd</code><br><code>sudo make</code> |
| **Install with Checkinstall or Make** | Generate a Debian package for easy uninstallation:<br><code>sudo checkinstall</code> <br/>Alternatively:<br><code>sudo make install</code> |
| **Update Kernel Modules** | <code>depmod</code> |
| **Load Module** | <code>modprobe facetimehd</code> |
| **Verify Module** | Check loaded modules:<br><code>lsmod \| grep facetimehd</code> |
| **Test Camera** | Open camera with MPlayer:<br><code>mplayer -vo gl tv://</code> |
| **Troubleshoot** | If not working, reload the module:<br><code>sudo modprobe -r facetimehd</code><br><code>sudo modprobe facetimehd</code><br>If camera quality is poor, reboot your MacBook. |

## Method 2: Ubuntu

### Step 1: build and install the kernel module for Ubuntu ([More detail click here](https://github.com/patjak/facetimehd/wiki/Installation#get-started-on-ubuntu)).

| Step | Command/Description |
|------|--------------------|
| **Compile Driver** | <code>cd ~/facetimehd</code><br><code>sudo make</code> |
| **Install Driver** | <code>sudo make install</code> |
| **Update Kernel Modules** | <code>depmod</code> |
| **Remove bdc_pci (if exists)** | <code>sudo modprobe -remove --quiet bdc_pci</code> |
| **Load Driver** | <code>sudo modprobe facetimehd</code> |
| **Fix BTF Error** | If you see `Skipping BTF generation` error:<br><code>cd ~/facetimehd</code><br><code>sudo cp /sys/kernel/btf/vmlinux /usr/lib/modules/\`uname -r\`/build/</code> |
| **Verify Module** | <code>lsmod \| grep facetimehd</code> |
| **Test Camera** | <code>mplayer -vo gl tv://</code> |
| **Troubleshoot** | If not working, reload the module:<br><code>sudo modprobe -r facetimehd</code><br><code>sudo modprobe facetimehd</code><br>If camera quality is poor, reboot your MacBook. |

### Step 2: DKMS Installation

| Step | Command/Description |
|------|--------------------|
| **Remove Old Package** | <code>sudo dpkg -r bcwc-pcie</code> |
| **Create Directory** | <code>sudo mkdir /usr/src/facetimehd-0.1</code> |
| **Copy Files** | <code>cd ~/facetimehd</code><br><code>sudo cp -r * /usr/src/facetimehd-0.1/</code> |
| **Clean Previous Build** | <code>cd /usr/src/facetimehd-0.1/</code><br><code>sudo rm backup-*tgz bcwc-pcie_*deb</code><br><code>sudo make clean</code> |
| **Register with DKMS** | <code>sudo dkms add -m facetimehd -v 0.1</code> |
| **Build Module** | <code>sudo dkms build -m facetimehd -v 0.1</code> |
| **Build Debian Packages** | <code>sudo dkms mkdsc -m facetimehd -v 0.1 --source-only</code><br><code>sudo dkms mkdeb -m facetimehd -v 0.1 --source-only</code> |
| **Copy Debian Package** | <code>sudo cp /var/lib/dkms/facetimehd/0.1/deb/facetimehd-dkms_0.1_all.deb /root/</code> |
| **Clean DKMS** | <code>sudo rm -r /var/lib/dkms/facetimehd/</code> |
| **Install Package** | <code>sudo dpkg -i /root/facetimehd-dkms_0.1_all.deb</code> |
| **Verify Module** | <code>lsmod \| grep facetimehd</code> |
| **Test Camera** | <code>mplayer -vo gl tv://</code> |
| **Troubleshoot** | If not working, reload the module:<br><code>sudo modprobe -r facetimehd</code><br><code>sudo modprobe facetimehd</code><br>If camera quality is poor, reboot your MacBook. |

## Notes
- **Reboot**: If the camera quality is poor after installation, reboot your MacBook.
- **References**:
  - [Extracting Sensor Calibration Files](https://github.com/patjak/facetimehd/wiki/Extracting-the-sensor-calibration-files)
  - [Get Started: Firmware Extraction](https://github.com/patjak/facetimehd/wiki/Get-Started#firmware-extraction)
  - [Debian Installation](https://github.com/patjak/facetimehd/wiki/Installation#get-started-on-debian)
  - [Ubuntu Installation](https://github.com/patjak/facetimehd/wiki/Installation#get-started-on-ubuntu)
- **Testing**: Use `mplayer -vo gl tv://` to test the camera after each method.

## Many thanks to
- Patrik Jakobsson https://github.com/patjak/facetimehd
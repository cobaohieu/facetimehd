#!/bin/bash

#################################################################
# Install neccessary software first
sudo apt install -y gcc-12
sudo apt install -y xz-utils curl cpio make dwarves
sudo apt install -y linux-headers-generic git kmod libssl-dev checkinstall
sudo apt install -y debhelper dkms
sudo apt install -y mplayer

#################################################################
# Build driver
git clone https://github.com/patjak/facetimehd.git
cd facetimehd/firmware
git clone https://github.com/patjak/facetimehd-firmware.git  .

# For Extracting the sensor calibration files
# please refer this link below
# https://github.com/patjak/facetimehd/wiki/Extracting-the-sensor-calibration-files

# Download driver package from https://support.apple.com/kb/DL1837
# Or you could check the Windows drivers for your own macbook on Apple.com
# Unzip the package with unzip
cd ~/Downloads/
unzip bootcamp5.1.5769.zip -d ~/Downloads/bootcamp5.1.5769/

# Extract AppleCamera64.exe
unrar x bootcamp5.1.5769/BootCamp/Drivers/Apple/AppleCamera64.exe

# You should now have the AppleCamera.sys file which is the driver containing the set files.
ls bootcamp5.1.5769/BootCamp/Drivers/Apple/ | grep AppleCamera.sys

# Run the following commands
dd bs=1 skip=1663920 count=33060 if=AppleCamera.sys of=9112_01XX.dat
dd bs=1 skip=1644880 count=19040 if=AppleCamera.sys of=1771_01XX.dat
dd bs=1 skip=1606800 count=19040 if=AppleCamera.sys of=1871_01XX.dat
dd bs=1 skip=1625840 count=19040 if=AppleCamera.sys of=1874_01XX.dat

# Copy the .dat files into your facetimehd firmware directory (eg. /lib/firmware/facetimehd/)
sudo scp *.dat /lib/firmware/facetimehd/

# Next gone through this step below
# refer this link here: https://github.com/patjak/facetimehd/wiki/Get-Started#firmware-extraction
printf "Compiling firmware\n";
sudo make
printf "done\n\n";

printf "Installing firmware\n";
sudo make install
printf "done\n\n";

cd ..

#################################################################
# Refer this link here: https://github.com/patjak/facetimehd/wiki/Installation#get-started-on-debian
# Method 1:
cd ..
printf "Build the kernel module\n";
sudo make
printf "done\n\n";

## Use checkinstall or make install
### Use checkinstall
printf "Generate dkpg and install the kernel module, this is easy to uninstall later\n";
sudo checkinstall
printf "done\n\n";

### Or use make install
printf "Alternatively if you are really lazy just\n";
sudo make install

## Run depmod for the kernel to be able to find and load it
depmod
## Load kernel module
modprobe facetimehd

## Check if all relevant modules a loaded: 
lsmod | grep facetimehd

## try open camera with mplayer tv://
mplayer -vo gl tv://

# If is not working please run 2 commands below and run again
sudo modprobe -r facetimehd
sudo modprobe facetimehd

## If it is working but the camera is so bad, please reboot your macbook

#######################################
# Refer this link here: https://github.com/patjak/facetimehd/wiki/Installation#get-started-on-ubuntu
# Method 2:
printf "Compiling driver\n";
sudo make
printf "done\n\n";

printf "Installing driver\n";
sudo make install
printf "done\n\n";

printf "Running depmod\n";
sudo depmod
printf "done\n\n";

printf "modprobe remove bdc_pci (if it exists)\n";
sudo modprobe -remove --quiet bdc_pci
printf "done\n\n";

printf "Loading driver\n";
sudo modprobe facetimehd
printf "done\n\n";


# You got the error as below
# Skipping BTF generation for /home/cobaohieu/bcwc_pcie/facetimehd.ko due to unavailability of vmlinux
# Please do this step
cd ~/bcwc_pcie
sudo cp /sys/kernel/btf/vmlinux /usr/lib/modules/`uname -r`/build/

#


# Step 3:
# Remove old package if installed: 
sudo dpkg -r bcwc-pcie 

# Make a directory to work from:
sudo mkdir /usr/src/facetimehd-0.1

# Change into the git repo dir: $ 
cd ~/bcwc_pcie

# Copy files over:
sudo cp -r * /usr/src/facetimehd-0.1/

# Change into that dir: 
cd /usr/src/facetimehd-0.1/

# Remove any previous debs and backups: 
sudo rm backup-*tgz bcwc-pcie_*deb

# Clear out previous compile: 
sudo make clean

# Register the new module with DKMS: 
sudo dkms add -m facetimehd -v 0.1

# Build the module: 
sudo dkms build -m facetimehd -v 0.1

# Build a Debian source package: 
sudo dkms mkdsc -m facetimehd -v 0.1 --source-only

# Build a Debian binary package: 
sudo dkms mkdeb -m facetimehd -v 0.1 --source-only

# Copy deb locally: 
sudo cp /var/lib/dkms/facetimehd/0.1/deb/facetimehd-dkms_0.1_all.deb /root/

# Get rid of the local build files: 
sudo rm -r /var/lib/dkms/facetimehd/

# Install the new deb package: 
sudo dpkg -i /root/facetimehd-dkms_0.1_all.deb

## Check if all relevant modules a loaded: 
lsmod | grep facetimehd

# try open camera with mplayer tv://
mplayer -vo gl tv://

# If is not working please run 2 commands below and run again
sudo modprobe -r facetimehd
sudo modprobe facetimehd

# If it is working but the camera is so bad, please reboot your macbook



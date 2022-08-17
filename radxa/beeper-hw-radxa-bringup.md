# BeeperHW Board Bringup
## Radxa


## Install Ubuntu
### Dependencies
```
brew install libusb python
pip3 install pyamlboot
```

### Erase MMC
Hold the USB Boot button on the back of the Radxa and plug in the usb-c OTG cable to your computer

```
# First get this aml image 
wget https://dl.radxa.com/zero/images/loader/radxa-zero-erase-emmc.bin
# Flash it to fully erase the eMMC on the Radxa
boot-g12.py ./radxa-zero-erase-emmc.bin
```

### Setup eMMC udisk storage

```
# Download the udisk-storage bootloader
wget https://dl.radxa.com/zero/images/loader/rz-udisk-loader.bin
# Flash bin to get a usb-class-storage access to eMMC
boot-g12.py ./rz-udisk-loader.bin
```

Device should now show up as a usb class storage device.  On mac, this will pop up a dialog saying the disk is uninitialized.. Click Ignore

More info can be found at: https://wiki.radxa.com/Zero/dev/maskrom#Enable_maskrom

### Flash Armbian image
```
# Download ubuntu server image from radxa's github
wget https://github.com/radxa-build/radxa-zero/releases/download/20220801-0213/radxa-zero-ubuntu-focal-server-arm64-20220801-0346-mbr.img.xz

# Decompress image
unxz radxa-zero-ubuntu-focal-server-arm64-20220801-0346-mbr.img.xz

# Flash using dd
sudo dd if=radxa-zero-ubuntu-focal-server-arm64-20220801-0346-mbr.img of=/dev/disk4 bs=1m
```

Once this completes, unplug and replug the device and wait for it to show up in adb

```
➜  beeperhw adb devices
List of devices attached
0123456789ABCDEF	device
```



## Setup Linux 

The radxa ubuntu build contains adb support, so we can access the shell with:
```
adb shell
```

##### Configure Wifi

```
sudo nmcli radio wifi on
```
```
# nmcli dev wifi list
IN-USE  BSSID              SSID             MODE   CHAN  RATE        SIGNAL  BARS  SECURITY
        6C:CD:D6:D7:82:0F  NETGEAR51        Infra  1     195 Mbit/s  100     ▂▄▆█  WPA2
        6C:CD:D6:D7:82:0E  NETGEAR51-5G     Infra  153   405 Mbit/s  100     ▂▄▆█  WPA2
        BC:A5:11:FA:0D:86  RDMeOffice       Infra  2     130 Mbit/s  85      ▂▄▆█  WPA2
        E4:71:85:30:54:48  The Internet 02  Infra  149   405 Mbit/s  77      ▂▄▆_  WPA1 WPA2
        BC:A5:11:FA:0D:88  RDMeOffice-5G    Infra  149   270 Mbit/s  77      ▂▄▆_  WPA2
        E4:71:85:30:54:4C  The Internet 01  Infra  9     195 Mbit/s  75      ▂▄▆_  WPA1 WPA2
        B0:4E:26:73:48:33  TP-Link_4833     Infra  11    195 Mbit/s  72      ▂▄▆_  WPA1 WPA2
```

```
sudo nmcli dev wifi connect NETGEAR51-5G password "network-password"
```

Give the system a few minutes to connect and sync up.  Ensure datetime is correct / set via NTP before proceeding

##### Build Environment
```
sudo apt install build-essential wget device-tree-compiler
```

##### Sharp LCD Driver 

The main display is driven with this driver: https://github.com/kylehawes/Sharp-Memory-LCD-Kernel-Driver


First compile the kernel modules
```
cd ~
wget -O sharp-lcd.tar.gz https://github.com/billylindeman/Sharp-Memory-LCD-Kernel-Driver/archive/refs/heads/master.tar.gz 
cd Sharp-Memory-LCD-Kernel-Driver-master/
make
make modules_install
depmod -A
echo sharp >> /etc/modules
```

Compile device tree overlay, and add it to the /boot

```
dtc -@ -I dts -O dtb -o sharp.dtbo sharp-radxa-zero.dts
cp sharp.dtbo /boot/dtbs/5.10.69-12-amlogic-g98700611d064/amlogic/overlay
```


Edit  `/boot/uEnv.txt` to support spidev and add the following configs for the sharp driver

```
overlays=meson-g12a-uart-ao-a-on-gpioao-0-gpioao-1 meson-g12a-spi-spidev sharp
param_spidev_spi_bus=1
param_spidev_max_freq=10000000
extraargs=fbcon=map:0 fbcon=font:VGA8x8 framebuffer_width=400 framebuffer_height=240
```

Now reboot and it should work!
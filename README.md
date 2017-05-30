# Infoboard
Scripts and instructions for making infoboard from Raspberry pi

## What is it?
Infoboard makes Raspberry Pi to show pictures on attached display on HDMI-port *using framebuffer* and **without needing X**, so infoboard is very lightweight. Uploading new pictures makes them to show up automatically, so all that is needed is to upload new pictures into place and/or remove old ones and they will show up on display. Majority of instructions should work on any Systemd based OS, but these is made specifically for Raspberry Pi with Debian Jessie in mind.

## Daily usage
Just copy wanted imagefile(s) (png and jpg preferred) into device with SFTP:

```
sftp infoboard@infoboard@<IP-address>
```
And give command:

```
put <imagefile.png>
```

or use your GUI filemanager like Nautilus, or Winscp in Windows.

## Installation
First install Raspbian Jessie from https://github.com/debian-pi/raspbian-ua-netinst (I used 1.0.9, shouldn't matter too much as long Jessie is being installed).

SSH into raspberry as root, password: raspbian

```
ssh root@<IP-address>
```

Then let's install basic tools, configure system basics and install fbi (FrameBuffer Imageviewer):

```
apt-get update && apt-get dist-upgrade
apt-get install -y raspi-config raspi-copies-and-fills fbi locales tzdata nano
dpkg-reconfigure locales # Choose appropriate locales and timezone for you, usually en_US.UTF-8 and some local one, for system default I recommend en_US.UTF-8
dpkg-reconfigure tzdata
```

Edit /boot/cmdline.txt and add consoleblank=0 onto the line there, this disables display to turn off after awhile

```
nano /boot/cmdline.txt
```

(ctrl+x exits Nano)

Download needed files, I'll use just wget at the example but you could use git to pull this repository too:

```
wget https://raw.githubusercontent.com/vaasahacklab/infoboard/master/infoboard.conf
wget https://raw.githubusercontent.com/vaasahacklab/infoboard/master/infoboard.sh
wget https://raw.githubusercontent.com/vaasahacklab/infoboard/master/picture-watchdog.service
wget https://raw.githubusercontent.com/vaasahacklab/infoboard/master/picture-watchdog.sh
```

Make shellscripts executable:

```
chmod +x *.sh
```

Create user for storing/uploading pictures (no root access or shell login access for this user and as we are going to use ssh chroot we need homedir to be owned by root, hence next method of creating a user)

```
groupadd sftp
useradd -c "Vaasa Hacklab infoboard" -g sftp -M -N -d /home/infoboard -s /bin/false infoboard
mkdir -p /home/infoboard/Pictures
chown -R root:sftp /home/infoboard
chmod 775 /home/infoboard/Pictures/
passwd infoboard
```

then edit /etc/ssh/sshd_config

```
nano /etc/ssh/sshd_config
```

and add this to end of file

```
Match Group sftp
    ChrootDirectory %h
    ForceCommand internal-sftp
    AllowTcpForwarding no
```

Restart ssh daemon:

```
systemctl restart ssh.service
```

Move systemd unit-files infoboard.conf and picture-watchdog.service into proper places:

```
mkdir /etc/systemd/system/getty@tty1.service.d
mv infoboard.conf /etc/systemd/system/getty@tty1.service.d/
mv picture-watchdog.service /lib/systemd/system/
```

Then make installed units to be run at every boot automatically and start them:

```
systemctl daemon-reload
systemctl enable getty@tty1.service
systemctl start getty@tty1.service
systemctl enable picture-watchdog.service
systemctl start picture-watchdog.service
```

## Optional

Highly recommended is to also add sudo user for maintenance, not for public usage, and disable root login:

SSH into raspberry as root, password: raspbian

```
ssh root@<IP-address>
```

Generate new user for admin things:

```
useradd -c "Vaasa Hacklab" -d /home/hacklab -m -s /bin/bash -U -G sudo hacklab
passwd hacklab
exit
```

then ssh with new user:

```
ssh hacklab@<IP-address>
```

then run to disable root login:

```
sudo passwd -l root
exit
```

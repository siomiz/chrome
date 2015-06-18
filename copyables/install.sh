#!/bin/bash
set -e

cd /tmp

apt-get update

DEBIAN_FRONTEND=noninteractive \
	apt-get install -y wget gdebi-core pulseaudio

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb

DEBIAN_FRONTEND=noninteractive gdebi -n *.deb

rm *.deb

apt-get purge -y wget gdebi-core
apt-get autoremove --purge -y
apt-get clean

rm -rf /var/lib/apt/* /var/lid/dpkg/* /var/cache/* /var/log/apt/*

addgroup chrome-remote-desktop
useradd -m -G chrome-remote-desktop,pulse-access chrome

cd /

chmod +x /crdonly

exit 0

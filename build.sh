#!/bin/bash

HomePage="$1"

if [[ "$HomePage" == "" ]]; then
	echo -n "
Build Kiosk Chromium Workspace.

$(basename $0) [Homepage]
  
    Examples:
        $(basename $0) https://google.com
"
    exit 1
fi

if [ "$(whoami)" != 'root' ]; then
    echo $"You have no permission to run $0 as non-root user. Use sudo"
    exit 1;
fi

apt update && apt upgrade -y
apt install -y mc htop nano
apt install --no-install-recommends xorg openbox pulseaudio git tar unzip -y
apt install upstart-sysv xserver-xorg-legacy -y
apt install matchbox-window-manager -y
usermod -aG audio u
usermod -aG video u
echo '
#! /bin/bash
xset -dpms
xset s off
start-pulseaudio-x11
exec matchbox-window-manager -use_titlebar no &
while true; do
   docker run -ti --privileged --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix chromium-browser
done' > /opt/finestart.sh

chmod +x /opt/finestart.sh

echo "
start on (filesystem and stopped udevtrigger)
stop on runlevel [06]

console output
emits starting-x

respawn

exec sudo -u u startx /etc/X11/Xsession /opt/finestart.sh --
" > /etc/init/finestart.conf

sed -i 's!allowed_users=console!#allowed_users=console!' /etc/X11/Xwrapper.config
echo "
allowed_users=anybody
needs_root_rights = yes
" >> /etc/X11/Xwrapper.config

apt install -y libnss3-dev libcups2-dev libgconf2-dev libxss-dev libatk1.0-dev libgtkglextmm-x11-1.2-dev
echo "cgroup /sys/fs/cgroup cgroup defaults,blkio,net_cls,freezer,devices,cpuacct,cpu,cpuset,memory,clone_children 0 0" >> /etc/fstab
sed -i 's!#GRUB_HIDDEN_TIMEOUT=0!GRUB_HIDDEN_TIMEOUT=0!' /etc/default/grub
sed -i 's!GRUB_TIMEOUT=2!GRUB_TIMEOUT=0!' /etc/default/grub
sed -i 's!GRUB_CMDLINE_LINUX_DEFAULT=""!GRUB_CMDLINE_LINUX_DEFAULT="quiet splash cgroup_enable=memory,namespace"!' /etc/default/grub
update-grub
sed -i 's!title=Ubuntu 16.04!title=<<< Welcome >>>!' /usr/share/plymouth/themes/text.plymouth
sed -i 's!title=Ubuntu 16.04!title=<<< Welcome >>>!' /usr/share/plymouth/themes/ubuntu-text/ubuntu-text.plymouth
update-initramfs -u

apt install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt-get install docker-ce -y
#mkdir /sys/fs/cgroup/systemd
usermod -aG docker u
tar xvzf chromium.tar.gz
echo "
FROM ubuntu:14.04

RUN mkdir -p /home/kiosk && \
    echo \"kiosk:x:1000:1000:kiosk,,,:/home/kiosk:/bin/bash\" >> /etc/passwd && \
    echo \"kiosk:x:1000:\" >> /etc/group && \
    echo \"kiosk ALL=(ALL) NOPASSWD: ALL\" > /etc/sudoers.d/kiosk && \
    chmod 0440 /etc/sudoers.d/kiosk && \
    chown 1000:1000 -R /home/kiosk

RUN apt-get update
RUN apt-get install chromium-browser dbus-x11 packagekit-gtk3-module libcanberra-gtk-module -y
RUN chown -R kiosk:kiosk /home/kiosk
RUN mkdir /var/run/dbus/
RUN mkdir /home/kiosk/.config/
USER kiosk
COPY --chown=1000:1000 chromium /home/kiosk/.config/chromium
ENV HOME /home/kiosk
CMD chromium-browser --noerrdialogs --incognito --disable-pinch --app=$HomePage --window-size=1920,1020
" > dockerfile
docker build -t chromium-browser .
read -sn 1 -p "Finish ! Press any key to reboot"
echo -e "\n"
reboot now






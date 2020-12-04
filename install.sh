#!/bin/bash

USER_NAME="tomas"
USER_PWD="root"
ROOT_PWD="root"

pacman-key --init
pacman-key --populate archlinuxarm

pacman -S --noconfirm \
           vim mc sudo git sudo \
           networkmanager network-manager-applet \
           xorg-server xorg-init xf86-video-fbdev xorg-refresh \
           xfce4 xfce4-xkb-plugin lightdm lightdm-gtk-greeter

systemctl enable NetworkManager.service
systemctl enable lightdm.service

sed -i -E 's/^# (%wheel ALL=\(ALL\) ALL)/\1/g' /etc/sudoers
useradd -m -G wheel -s /bin/bash $USER_NAME
printf "$USER_PWD\n$USER_PWD\n" | passwd $USER_NAME
printf "$ROOT_PWD\n$ROOT_PWD\n" | passwd

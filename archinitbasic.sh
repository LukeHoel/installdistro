#!/bin/sh

# Device to install on, fill in manually, then remove exit 1
installDevice=
# System config
timeZone="America/Toronto"
localeGen="en_US.UTF-8 UTF-8"
localeConf="LANG=en_US.UTF-8"
hostName="archlinux"

# Remove this after you've set everything up how you want it
exit 1

read -p "Proceed with installation? This will wipe the device $installDevice (yn) : " REPLY
if [[ $REPLY =~ ^[Yy]$ ]]
then
		#
		# System setup
		#

		# Wipe the device
		dd bs=512 count=1 if=/dev/zero of=$installDevice
		
		echo "	select $installDevice
				mklabel gpt
				mkpart primary 0% 100%
				set 1 bios_grub on" | parted

		rootPartition="${installDevice}1"

		# Init partitions
		yes | mkfs.ext4 $rootPartition

		# Mount partitions
		mount $rootPartition /mnt
		
		#
		# Follow the steps from the arch wiki
		#

		timedatectl set-ntp true
		pacstrap /mnt base base base-devel grub
		genfstab -U /mnt >> /mnt/etc/fstab
			
		# Run remaining commands under chroot
		arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/$timeZone /etc/localtime;
		hwclock --systohc;
		echo $localeGen > /etc/locale.gen;
		echo $localeConf > /etc/locale.conf;
		echo $hostName > /etc/hostname;	
		printf \"127.0.0.1 localhost\n::1 localhost\n127.0.1.1 $hostName.localdomain $hostName\" > /etc/hosts;
		grub-install --target=i386-pc $installDevice;
		grub-mkconfig -o /boot/grub/grub.cfg;"
fi 


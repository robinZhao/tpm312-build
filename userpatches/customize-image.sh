#!/bin/bash

# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP
#
# This is the image customization script

# NOTE: It is copied to /tmp directory inside the image
# and executed there inside chroot environment
# so don't reference any files that are not already installed

# NOTE: If you want to transfer files between chroot and host
# userpatches/overlay directory on host is bind-mounted to /tmp/overlay in chroot
# The sd card's root path is accessible via $SDCARD variable.

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

Main() {
	case $RELEASE in
		stretch)
			# your code here
			# InstallOpenMediaVault # uncomment to get an OMV 4 image
			;;
		buster)
			# your code here
			;;
		bullseye)
			# your code here
			;;
		bionic)
			# your code here
			;;
		focal)
			# your code here
			;;
                jammy)
			PostProcess                        
	                ;;
		noble)
  			PostProcess
   			;;
	esac
} # Main

PostProcess()
{
	if [[ "${BUILD_DESKTOP}" == "yes" ]];then
	    mv "${SDCARD}"/etc/apt/sources.list.d/armbian.list.disabled  "${SDCARD}"/etc/apt/sources.list.d/armbian.list
	    apt-get update
	    #if [[ "${ENABLE_EXTENSIONS}" =~ "mesa-vpu" ]];then
	    #   echo "mesa-vpu contains chromium"
	    #else
	       apt-get install -y chromium
	    #fi
	    apt-get install -y fcitx5 fcitx5-chinese-addons fcitx5-frontend-gtk4 fcitx5-frontend-gtk3 fcitx5-frontend-gtk2  fcitx5-frontend-qt5 fcitx5-config-qt fcitx5-modules 
	    cp --parents /usr/share/applications/org.fcitx.Fcitx5.desktop /etc/xdg/autostart/
	    if [[ "${DESKTOP_ENVIRONMENT}" == "gnome" ]];then
		apt-get install -y gnome-tweaks  gnome-shell-extension-prefs  chrome-gnome-shell gnome-shell-extension-manager
	    fi
	    mv "${SDCARD}"/etc/apt/sources.list.d/armbian.list  "${SDCARD}"/etc/apt/sources.list.d/armbian.list.disabled
	fi
	apt-get install -y vim
	systemctl mask hibernate.target
	systemctl mask suspend.target
}

InstallAdvancedDesktop()
{
	apt-get install -yy transmission libreoffice libreoffice-style-tango meld remmina thunderbird kazam avahi-daemon
	[[ -f /usr/share/doc/avahi-daemon/examples/sftp-ssh.service ]] && cp /usr/share/doc/avahi-daemon/examples/sftp-ssh.service /etc/avahi/services/
	[[ -f /usr/share/doc/avahi-daemon/examples/ssh.service ]] && cp /usr/share/doc/avahi-daemon/examples/ssh.service /etc/avahi/services/
	apt clean
} # InstallAdvancedDesktop

Main "$@"

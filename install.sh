#!/bin/bash
SU=sudo
HOME_DIR=$HOME
if [ "$(id -u)" -ne 0 ]; then
  echo "settings up $(id)"
else
    echo "Please run on the target user, not for root"
    exit 1
fi
. func.sh


setup_user() {
	echo "setting up user ..."
	INIT_DIR=$HOME_DIR/.config/rc/runlevels/sysinit

	if [ ! -d  $INIT_DIR ]; then 
		mkdir -p $INIT_DIR
	fi
	systemctl --user enable pipewire
	systemctl --user enable dbus
	systemctl --user enable wireplumber
	if [ ! -d $HOME_DIR/.config ]; then
		mkdir $HOME_DIR/.config
	fi
	# setup config
	if [ ! -f $HOME_DIR/.config/config_lock ]; then
		cp -r config/* $HOME_DIR/.config
		touch $HOME_DIR/.config/config_lock
		echo "config copied !"
	else
		echo "lock exist, skipping config overwrite ..."
	fi
}
$SU /bin/sh -c 'echo -ne "#!/bin/sh\ndbus-run-session -- Hyprland $@" > /bin/starthypr && chmod 777 /bin/starthypr'



echo "setting up artix linux ..."
$SU bash root.sh $(whoami) || exit
choice "do you want to install aur packages ?" "bash aur.sh || exit"
setup_user || exit
echo "\e[0;33m** Use command 'starthypr' to start your full desktop environment ** \e[0;0m"
echo "setup done ! please reboot your device"




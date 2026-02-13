USER=$1
if [ -z $USER ]; then
	echo "NULL user"
	exit
fi
echo "USER: $USER"
. func.sh

SU=
install_service() {
	echo "setting up service"
	$SU systemctl enable systemd-timesyncd
	$SU systemctl enable seatd
}
install_browser() {
	echo "setting up browser ..."
	$SU pacman -S firefox --noconfirm
}
install_network() {
	echo "setting up core ..."
	$SU pacman -S networkmanager --noconfirm
	$SU systemctl enable NetworkManager
}
setup_utils() {
	echo "setting up utils ..."
	# chmod +s $(which brightnessctl reboot poweroff)
	CUSTOM_SCRIPT=/bin/randomdis
	RANDOMDIS_SERVICE=/etc/systemd/system/randomdis.service
	BRIGHTNESSCTL=/etc/init.d/brightnessctl
	if [ ! -f $CUSTOM_SCRIPT ]; then
		$SU cp custom/randomdis $CUSTOM_SCRIPT
	fi
	if [ ! -f $RANDOMDIS_SERVICE ]; then
		$SU cp custom/randomdis.service $RANDOMDIS_SERVICE
	fi
	$SU systemctl enable randomdis
	# if [ ! -f $BRIGHTNESSCTL ]; then
	# 	$SU cp custom/brightnessctl $BRIGHTNESSCTL
	# fi
	# some script use /usr/bin/bash
	if [ ! -f /usr/bin/bash ]; then 
		$SU ln -s /bin/bash /usr/bin/bash
	fi
}
antkss() {
	$SU pacman -S usb_modeswitch mkinitcpio intel-ucode linux-firmware
	$SU bash fstab.sh
	$SU bash dev.sh
	$SU ln -sr /boot/initramfs-own.img /boot/initrd -f
	$SU ln -sr /boot/vmlinuz-own /boot/vmlinuz -f
	$SU mkdir -p /etc/pacman.d/hooks
	$SU cp custom/00-dkms-global-gcc.hook /etc/pacman.d/hooks
	$SU cp custom/dkms-global-gcc /usr/local/bin
	# optional linux-firmware
}
setup_source() {
	$SU bash ./source.sh
}
setup_clock() {
	$SU ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
	$SU hwclock --systohc

}
install_initial() {
	echo "setting up initialize packages ..."
	$SU pacman -S yay neovim --noconfirm
}
setup_group() {
	$SU usermod -aG video $USER
	$SU usermod -aG audio $USER
	$SU usermod -aG input $USER
}
nvidia() {
	bash ./nvidia.sh || exit
}
remove_sudodelay() {
	sed -i '/pam_faillock\.so/ { /nodelay/! s/$/ nodelay/ }' /etc/pam.d/system-auth
}
setup_source || exit
install_initial || exit
bash ./package.sh || exit
install_browser || exit
install_service || exit
install_network || exit
setup_utils || exit
choice "do you want to install nvidia packages ?" "nvidia || exit"
choice "do you want to install antkss packages ?" "antkss || exit"
setup_clock
setup_group
remove_sudodelay

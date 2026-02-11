#!/bin/bash
if [ "$(id -u)" -ne 0 ]; then
	echo "please run as root"
	exit
fi
sort_mirror() {
	pacman -S pacman-contrib parallel --noconfirm
	echo "getting mirrorlist ..."
	curl "https://archlinux.org/mirrorlist/?country=all&protocol=http&protocol=https&ip_version=4" -o /tmp/mirrorlist
	curl "https://raw.githubusercontent.com/antkss/dots-artix/refs/heads/main/rankmirrors" -o /tmp/rankmirrors
	sed -i '/#.*Server[[:space:]]*=/ s/#//' /tmp/mirrorlist
	chmod 777 /tmp/rankmirrors
	echo "getting the fastest ..."
	/tmp/rankmirrors -v -n 5 -p /tmp/mirrorlist | tee /etc/pacman.d/mirrorlist
	rm /tmp/mirrorlist
}
choice(){
    local text=$1
    local cmd=$2
    local p 
    local ask=false 

    echo "$text"

    while true; do
        read -p "(y|n) => " p
        case "$p" in
            [yY]) 
                ask=true
                break 
                ;;
            [nN]) 
                ask=false
                break 
                ;;
            *) 
                echo "Invalid input. Please enter 'y' for yes or 'n' for no."
                ;;
        esac
    done

    if [[ "$ask" == true ]]; then
        $cmd
    fi
}
choice "Do you want to sort the fastest arch mirror ?" sort_mirror


pacman-key --init
pacman-key --populate
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' --noconfirm
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm
echo "setting up server ..."
repo="\[antk\]"
repo_="[antk]"
server="Server = https://antkss.github.io/packages"
if [ ! -n "$(cat /etc/pacman.conf | grep $repo )" ]; then 
	echo "applying :$repo_ ..."
	echo -ne "\n$repo_\nSigLevel = Optional TrustAll\n$server" >> /etc/pacman.conf
fi
repo="\[chaotic-aur\]"
repo_="[chaotic-aur]"
server="Include = /etc/pacman.d/chaotic-mirrorlist"
if [ ! -n "$(cat /etc/pacman.conf | grep $repo )" ]; then 
	echo "applying :$repo_ ..."
	echo -ne "\n$repo_\n$server" >> /etc/pacman.conf
fi

pacman -Sy

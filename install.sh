#!/usr/bin/env bash
cd "$(dirname "$0")"
export base="$(pwd)"
source ./scriptdata/functions
source ./scriptdata/installers
source ./scriptdata/options

#####################################################################################
clear
if ! command -v pacman >/dev/null 2>&1;then printf "\e[31m[$0]: pacman not found, it seems that the system is not ArchLinux or Arch-based distros. Aborting...\e[0m\n";exit 1;fi
prevent_sudo_or_root
startask (){
printf "checking master git branch  ...\n"
git pull origin master
printf "\e[34m[$0]: Hi there!\n"
printf 'This script 1. only works for ArchLinux and Arch-based distros.\n'
printf '            2. has not been fully tested, use at your own risk.\n'
printf "\e[31m"
printf "Please CONFIRM that you HAVE ALREADY BACKED UP \"$HOME/.config/\" and \"$HOME/.local/\" folders!\n"
printf "\e[97m"
printf "Enter capital \"yes\" (without quotes) to continue:"
read -p " " p
case $p in "yes")sleep 0;; *)echo "Received \"$p\", aborting...";exit 1;;esac
clear
printf '\n'
printf 'Do you want to install ?\n'
printf '  y = Yes, continue\n'
printf '  a = Abort. (DEFAULT)\n'
read -p "====> " p
case $p in
  y)ask=true;;
   *)exit 1;;
esac
}
case $ask in
  false);;
  *)startask ;;
esac

set -e
#####################################################################################
printf "\e[36m[$0]: 1. Get packages and add user to video/input groups\n\e[97m"

remove_bashcomments_emptylines ./scriptdata/dependencies.conf ./cache/dependencies_stripped.conf
readarray -t pkglist < ./cache/dependencies_stripped.conf

if ! command -v yay >/dev/null 2>&1;then
  if ! command -v paru >/dev/null 2>&1;then
    echo -e "\e[33m[$0]: \"yay\" not found.\e[0m"
    showfun install-yay
    v install-yay
    AUR_HELPER=yay
  else
    echo -e "\e[33m[$0]: \"yay\" not found, but \"paru\" found.\e[0m"
    echo -e "\e[33mIt is not recommended to use \"paru\" as warned in Hyprland Wiki:\e[0m"
    echo -e "\e[33m    \"If you are using the AUR (hyprland-git) package, you will need to cleanbuild to update the package. Paru has been problematic with updating before, use Yay.\"\e[0m"
    echo -e "\e[33mReference: https://wiki.hyprland.org/FAQ/#how-do-i-update\e[0m"
    if $ask;then
      printf "Install \"yay\"?\n"
      printf "  y = Yes, install \"yay\" for me first. (DEFAULT)\n"
      printf "  n = No, use \"paru\" at my own risk.\n"
      printf "  a = Abort.\n"
      sleep 2
      read -p "====> " p
      case $p in
        [Nn]) AUR_HELPER=paru;;
        [Aa]) echo -e "\e[34mAlright, aborting...\e[0m";exit 1;;
        *) v paru -S --needed --noconfirm yay-bin;
           AUR_HELPER=yay;;
      esac
    else
      AUR_HELPER=paru
    fi
  fi
else AUR_HELPER=yay
fi

  # execute for all elements of the array $pkglist in one line
  printf "setting up mirrors ..."
sudo ./source.sh
v $AUR_HELPER -Sy --needed --noconfirm --config ./pacman.conf ${pkglist[*]}
printf "enter sudo password !!!!\n"
v sudo usermod -aG video,input "$(whoami)"

#####################################################################################
printf "\e[36m[$0]: 2. Installing parts from source repo\e[97m\n"
sleep 1

if command -v ags >/dev/null 2>&1;then
  echo -e "\e[33m[$0]: Command \"ags\" already exists, no need to install.\e[0m"
  echo -e "\e[34mYou can reinstall it in order to update to the latest version anyway.\e[0m"
  ask_ags=$ask
else ask_ags=true
fi
if $ask_ags;then showfun install-ags;v install-ags;fi
clear
printf "changing shell to fish...\n"
printf "please enter sudo password !!!!\n"
chsh -s /usr/bin/fish
clear
printf "Your actions will overwrite all the existing configurations, do you want to continue?\n"
printf " y = Yes, continue:\n"
printf " n = No, skip:\n"
printf " type anything else to abort:\n"
overwrite(){
read -p "====> " p
case $p in
  y)ask=true;;
  n)ask=false;;
  *)exit 1;;
esac

}

overwrite

if [[ $ask == true ]];then
printf "\e[36m[$0]: 3. Copying\e[97m\n"
cp -r ./.icons $HOME
cp -r ./config/* $HOME/.config
cp -r ./.images $HOME
cp -r ./.local $HOME
fi
sleep 1
clear
printf "Do you want to fully setup packages for your desktop ?\n"
printf " y = Yes, continue:\n"
printf " n = No, skip:\n"
printf " type anything else to abort:\n"
installfull(){
read -p "====> " p
case $p in
  y)ask=true;;
  *)ask=false;;
esac

}

installfull

if [[ $ask == true ]];then
./packages.sh
try hyprctl reload
fi
#####################################################################################
printf "\e[36m[$0]: Finished. See the \"Import Manually\" folder and grab anything you need.\e[97m\n"
printf "\e[36mPress \e[30m\e[46m Ctrl+Super+T \e[0m\e[36m to select a wallpaper\e[97m\n"
printf "\e[36mPress \e[30m\e[46m Super+/ \e[0m\e[36m for a list of keybinds\e[97m\n"
echo "See https://end-4.github.io/dots-hyprland-wiki/en for more info."
echo "XIN VUI LONG KHOI DONG LAI MAY"

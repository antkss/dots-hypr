#!/usr/bin/env bash

term_alpha=100 #Set this to < 100 make all your terminals transparent
# sleep 0 # idk i wanted some delay or colors dont get applied properly
if [ ! -d "$HOME"/.cache/ags/user/generated ]; then
    mkdir -p "$HOME"/.cache/ags/user/generated
fi
cd "$HOME/.config/ags" || exit

colornames=''
colorstrings=''
colorlist=()
colorvalues=()

# wallpath=$(swww query | head -1 | awk -F 'image: ' '{print $2}')
# wallpath_png="$HOME"'/.cache/ags/user/generated/hypr/lockscreen.png'
# convert "$wallpath" "$wallpath_png"
# wallpath_png=$(echo "$wallpath_png" | sed 's/\//\\\//g')
# wallpath_png=$(sed 's/\//\\\\\//g' <<< "$wallpath_png")

transparentize() {
  local hex=${colorvalues[27]}
  local alpha="$2"
  local red green blue

  red=$((16#${hex:1:2}))
  green=$((16#${hex:3:2}))
  blue=$((16#${hex:5:2}))

  printf '${colorvalues[27]}'
  printf 'rgba(%d, %d, %d, %.2f)\n' "$red" "$green" "$blue" "$alpha"
}

get_light_dark() {
    lightdark=""
    if [ ! -f "$HOME"/.cache/ags/user/colormode.txt ]; then
        echo "" > "$HOME"/.cache/ags/user/colormode.txt
    else
        lightdark=$(sed -n '1p' "$HOME/.cache/ags/user/colormode.txt")
    fi
    echo "$lightdark"
}

apply_fuzzel() {
    # Check if scripts/templates/fuzzel/fuzzel.ini exists
    if [ ! -f "scripts/templates/fuzzel/fuzzel.ini" ]; then
        echo "Template file not found for Fuzzel. Skipping that."
        return
    fi
    # Copy template
    mkdir -p "$HOME"/.cache/ags/user/generated/fuzzel
    cp "scripts/templates/fuzzel/fuzzel.ini" "$HOME"/.cache/ags/user/generated/fuzzel/fuzzel.ini
    # Apply colors
    for i in "${!colorlist[@]}"; do
        sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$HOME"/.cache/ags/user/generated/fuzzel/fuzzel.ini
    done

    cp  "$HOME"/.cache/ags/user/generated/fuzzel/fuzzel.ini "$HOME"/.config/fuzzel/fuzzel.ini
}

apply_hyprland() {
    # Check if scripts/templates/hypr/hyprland/colors.conf exists
    if [ ! -f "scripts/templates/hypr/hyprland/colors.conf" ]; then
        echo "Template file not found for Hyprland colors. Skipping that."
        return
    fi
    # Copy template
    mkdir -p "$HOME"/.cache/ags/user/generated/hypr/hyprland
    cp "scripts/templates/hypr/hyprland/colors.conf" "$HOME"/.cache/ags/user/generated/hypr/hyprland/colors.conf
    # Apply colors
    for i in "${!colorlist[@]}"; do
        sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$HOME"/.cache/ags/user/generated/hypr/hyprland/colors.conf
    done

    cp "$HOME"/.cache/ags/user/generated/hypr/hyprland/colors.conf "$HOME"/.config/hypr/hyprland/colors.conf
}

apply_hyprlock() {
    # Check if scripts/templates/hypr/hyprlock.conf exists
    if [ ! -f "scripts/templates/hypr/hyprlock.conf" ]; then
        echo "Template file not found for hyprlock. Skipping that."
        return
    fi
    # Copy template
    mkdir -p "$HOME"/.cache/ags/user/generated/hypr/
    cp "scripts/templates/hypr/hyprlock.conf" "$HOME"/.cache/ags/user/generated/hypr/hyprlock.conf
    # Apply colors
    # sed -i "s/{{ SWWW_WALL }}/${wallpath_png}/g" "$HOME"/.cache/ags/user/generated/hypr/hyprlock.conf
    for i in "${!colorlist[@]}"; do
        sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$HOME"/.cache/ags/user/generated/hypr/hyprlock.conf
    done

    cp "$HOME"/.cache/ags/user/generated/hypr/hyprlock.conf "$HOME"/.config/hypr/hyprlock.conf
}

apply_gtk() { # Using gradience-cli
    lightdark=$(get_light_dark)

    # Copy template
    mkdir -p "$HOME"/.cache/ags/user/generated/gradience
    cp "scripts/templates/gradience/preset.json" "$HOME"/.cache/ags/user/generated/gradience/preset.json

    # Apply colors
    for i in "${!colorlist[@]}"; do
        sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]}/g" "$HOME"/.cache/ags/user/generated/gradience/preset.json
    done

    mkdir -p "$HOME/.config/presets" # create gradience presets folder
    gradience-cli apply -p "$HOME"/.cache/ags/user/generated/gradience/preset.json --gtk both

    # Set light/dark preference
    # And set GTK theme manually as Gradience defaults to light adw-gtk3
    # (which is unreadable when broken when you use dark mode)
    if [ "$lightdark" = "light" ]; then
        gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    else
        gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    fi
}

apply_ags() {
    sass "$HOME"/.config/ags/scss/main.scss "$HOME"/.cache/ags/user/generated/style.css
    ags run-js 'openColorScheme.value = true; Utils.timeout(2000, () => openColorScheme.value = false);'
    ags run-js "App.applyCss('${HOME}/.cache/ags/user/generated/style.css');"

}

if [[ "$1" = "--bad-apple" ]]; then
    lightdark=$(get_light_dark)
    cp scripts/color_generation/specials/_material_badapple"${lightdark}".scss scss/_material.scss
    colornames=$(cat scripts/color_generation/specials/_material_badapple"${lightdark}".scss | cut -d: -f1)
    colorstrings=$(cat scripts/color_generation/specials/_material_badapple"${lightdark}".scss | cut -d: -f2 | cut -d ' ' -f2 | cut -d ";" -f1)
    IFS=$'\n'
    colorlist=( $colornames ) # Array of color names
    colorvalues=( $colorstrings ) # Array of color values
else
    colornames=$(cat scss/_material.scss | cut -d: -f1)
    colorstrings=$(cat scss/_material.scss | cut -d: -f2 | cut -d ' ' -f2 | cut -d ";" -f1)
    IFS=$'\n'
    colorlist=( $colornames ) # Array of color names
    colorvalues=( $colorstrings ) # Array of color values
fi
apply_stuff(){


# Check if terminal escape sequence template exists
if [ ! -f "scripts/templates/terminal/sequences.txt" ]; then
echo "Template file not found for Terminal. Skipping that."
return
fi
# Copy template
mkdir -p "$HOME"/.cache/ags/user/generated/terminal
cp "scripts/templates/terminal/sequences.txt" "$HOME"/.cache/ags/user/generated/terminal/sequences.txt
# check if onedark plugin exist 
if [ -d "$HOME/.local/share/nvim/lazy/onedark.nvim" ]; then
# apply colors for neovim background 
# if the folder exist then do the operations
mv $HOME/.local/share/nvim/lazy/onedark.nvim/lua/onedark/palette.lua $HOME/.local/share/nvim/lazy/onedark.nvim/lua/onedark/palette.lua.bak
# Check if scripts/templates/onedark/palette.lua exists
if [ ! -f "scripts/templates/onedark/palette.lua" ]; then
    echo "Template file not found for onedark. Skipping that."
    return
fi
# Copy template
mkdir -p "$HOME"/.cache/ags/user/generated/onedark
cp "scripts/templates/onedark/palette.lua" "$HOME"/.cache/ags/user/generated/onedark/palette.lua
# Apply colors
# sed -i "s/{{ SWWW_WALL }}/${wallpath_png}/g" "$HOME"/.cache/ags/user/generated/hypr/hyprlock.conf
for i in "${!colorlist[@]}"; do
    sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$HOME"/.cache/ags/user/generated/onedark/palette.lua
done

cp "$HOME"/.cache/ags/user/generated/onedark/palette.lua $HOME/.local/share/nvim/lazy/onedark.nvim/lua/onedark/palette.lua
if [ ! -f "scripts/templates/onedark/palette.lua" ]; then
    echo "Template file not found for onedark. Skipping that."
    return
fi
# Copy template
mkdir -p "$HOME"/.cache/ags/user/generated/vimline
    cp "scripts/templates/vimline/powerline.lua" "$HOME"/.cache/ags/user/generated/vimline/powerline.lua
    # Apply colors
    # sed -i "s/{{ SWWW_WALL }}/${wallpath_png}/g" "$HOME"/.cache/ags/user/generated/hypr/hyprlock.conf
    for i in "${!colorlist[@]}"; do
        sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$HOME"/.cache/ags/user/generated/vimline/powerline.lua
    done

    cp "$HOME"/.cache/ags/user/generated/vimline/powerline.lua $HOME/.config/nvim/lua/config/powerline.lua
          else 
		  #if it doesn't exist then 
		  notify-send "onedark please install them for neovim material themes support\n link onedark: https://github.com/antkss/onedark.nvim"
    fi
########################### the end of neovim #################################################

##############apply for foot and alacritty #################################
# if [ -d "$HOME/.config/foot" ]; then
# 	if [[ -z $(cat $HOME/.config/foot/foot.ini | grep /.config/foot/colors.ini) ]]; then
# 		echo "[main]
# include=~/.config/foot/colors.ini" >> $HOME/.config/foot/foot.ini
# 	fi

mkdir -p "$HOME"/.cache/ags/user/generated/foot
cp "$HOME"/.config/ags/scripts/templates/foot/colors.ini "$HOME"/.cache/ags/user/generated/foot/colors.ini
for i in "${!colorlist[@]}"; do
    sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$HOME"/.cache/ags/user/generated/foot/colors.ini
done
cp "$HOME"/.cache/ags/user/generated/foot/colors.ini $HOME/.config/foot/colors.ini

mkdir -p "$HOME"/.cache/ags/user/generated/alacritty
cp "$HOME"/.config/ags/scripts/templates/alacritty/color.toml "$HOME"/.cache/ags/user/generated/alacritty/color.toml
for i in "${!colorlist[@]}"; do
    sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$HOME"/.cache/ags/user/generated/alacritty/color.toml
done
cp "$HOME"/.cache/ags/user/generated/alacritty/color.toml $HOME/.config/alacritty/color.toml
# echo "
# [colors.normal]
# black = \"0x10100E\"
# blue = \"0x${colorvalues[27]:1}\"
# cyan = \"0x20B2AA\"
# green = \"0x${colorvalues[2]:1}\"
# magenta = \"0x9A4EAE\"
# red = \"0x${colorvalues[2]:1}\"
# white = \"0x${colorvalues[20]:1}\"
# yellow = \"0x${colorvalues[53]:1}\"
# [colors.primary]
# background = \"0x${colorvalues[7]:1}\"
# foreground = \"0xcbe3e7\"
# " > "$HOME"/.config/alacritty/color.toml

# for i in "${!colorlist[@]}"; do
#  echo "${colorlist[$i]}:[$i] ${colorvalues[$i]}"
# done

}
apply_ags 
sleep 0.1
apply_stuff 
sleep 0.1
apply_hyprland   
sleep 0.1
apply_hyprlock 
sleep 0.1 
apply_gtk 
sleep 0.1 
apply_fuzzel 
transparentize

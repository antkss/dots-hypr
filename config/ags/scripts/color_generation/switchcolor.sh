#!/usr/bin/bash
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG_DIR="$XDG_CONFIG_HOME/ags"
color=$(hyprpicker --no-fancy -z )
echo $color
"$CONFIG_DIR"/scripts/color_generation/generate_colors_material.py --color $color --apply --mode light
# killall simple-bar;~/.config/ags/simple-bar

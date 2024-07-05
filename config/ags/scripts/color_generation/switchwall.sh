#!/usr/bin/env bash

if [ "$1" == "--noswitch" ]; then
    imgpath=$(swww query | head -1 | awk -F 'image: ' '{print $2}')
    # imgpath=$(ags run-js 'wallpaper.get(0)')
else
    # Select and set image (hyprland)
	cd "$HOME/.images"
	imgpath=$(yad --width 1000 --height 600 --file --title='Choose wallpaper' --add-preview --large-preview &)
	if file --mime-type "$imgpath" | grep -q "image/gif" || file --mime-type "$imgpath" | grep -q "video"; then
		mv $imgpath $HOME/.cache/target
		cd $HOME/.cache
		ffmpeg -y -i target -filter_complex "[v:0]crop=iw:ih" -frames:v 1 -f image2 output%03d_swww.png
		mv $HOME/.cache/target $imgpath  
		if file --mime-type "$imgpath" | grep -q "image/gif"; then
		notify-send "applying gif ..."
		gifpath=$imgpath
		fi
		imgpath="$HOME/.cache/output001_swww.png"
		# screensizey=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f2 | head -1)
		# cursorposx=$(hyprctl cursorpos -j | gojq '.x' 2>/dev/null) || cursorposx=960
		# cursorposy=$(hyprctl cursorpos -j | gojq '.y' 2>/dev/null) || cursorposy=540
		# cursorposy_inverted=$(( screensizey - cursorposy ))
	fi

	if [ "$imgpath" == '' ]; then
		echo 'Aborted'
	exit 0
	fi
	if [ -v gifpath ]; then
		swww img $gifpath
		notify-send "waiting for gif to finish..."
	else
		swww img "$imgpath" 
	fi
	screensizey=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f2 | head -1)
	cursorposx=$(hyprctl cursorpos -j | gojq '.x' 2>/dev/null) || cursorposx=960
	cursorposy=$(hyprctl cursorpos -j | gojq '.y' 2>/dev/null) || cursorposy=540
	cursorposy_inverted=$(( screensizey - cursorposy ))
	# --transition-step 100 
	# --transition-type grow --transition-angle 30 --transition-duration 1 \
	# --transition-pos "$cursorposx, $cursorposy_inverted"
fi

&>/dev/null
# Generate colors for ags n stuff
"$HOME"/.config/ags/scripts/color_generation/generate_colors_material.py --path ${imgpath} --scheme primary --apply 
# "$HOME"/.config/ags/scripts/color_generation/colorgen.sh "${imgpath}" --apply

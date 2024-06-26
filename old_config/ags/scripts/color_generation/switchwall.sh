#!/usr/bin/env bash

if [ "$1" == "--noswitch" ]; then
    imgpath=$(swww query | awk -F 'image: ' '{print $2}')
    imgpath=$(ags run-js 'wallpaper.get(0)')
else
    # Select and set image (hyprland)
    cd "$HOME/.images"
    imgpath=$(yad --width 800 --height 500 --file --title='Choose wallpaper')
    screensizey=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f2 | head -1)
    cursorposx=$(hyprctl cursorpos -j | gojq '.x' 2>/dev/null) || cursorposx=960
    cursorposy=$(hyprctl cursorpos -j | gojq '.y' 2>/dev/null) || cursorposy=540
    cursorposy_inverted=$(( screensizey - cursorposy ))

    if [ "$imgpath" == '' ]; then
        echo 'Aborted'
        exit 0
    fi


    # ags run-js "wallpaper.set('')"
    # sleep 0.1 && ags run-js "wallpaper.set('${imgpath}')" &
    # options for your wtf idea =))) 
    # rm /usr/share/hyprland/wall_2K.png
    # ffmpeg -i $imgpath -vf scale=1920x1080 /usr/share/hyprland/wall_2K.png 
    # options for your normal idea
    swww img "$imgpath" --transition-step 100 --transition-fps 60 \
    --transition-type grow --transition-angle 30 --transition-duration 1 \
    --transition-pos "$cursorposx, $cursorposy_inverted"
fi

# Generate colors for ags n stuff
"$HOME"/.config/ags/scripts/color_generation/colorgen.sh "${imgpath}" --apply

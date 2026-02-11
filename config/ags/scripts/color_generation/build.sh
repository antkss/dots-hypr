#!/bin/sh
if [ -z $(which appimagetool) ];then
	yay -S appimagetool-bin
fi
PWDDIR=$(pwd)
if [ -f ./venv ]; then
	python3.13 -m venv venv
fi
source venv/bin/activate
pip3 install pillow materialyoucolor pyinstaller
pyinstaller generate_colors_material.py 
cd dist/generate_colors_material
cp -r $PWDDIR/assets/* .
cd ..
appimagetool generate_colors_material
mv color_generator-x86_64.AppImage ../generate_colors_material

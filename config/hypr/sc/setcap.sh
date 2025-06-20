#!/bin/sh
imgpath=/tmp/capset.png;
grim /tmp/capset.png
swww img "$imgpath" --transition-step 100 --transition-fps 120 \
	  --transition-type grow --transition-angle 30 --transition-duration 1 \
	  --transition-pos 0.854,0.977;
rm /tmp/capset.png;

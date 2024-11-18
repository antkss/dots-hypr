#!/usr/bin/bash
rm -r build
meson build . 
cd build;
ninja;
mv style.css simple-bar ..
cd ..

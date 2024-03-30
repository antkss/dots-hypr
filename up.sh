#!/bin/bash
cd ~/.cache/dots-hypr
rm -r ~/.config/ags
rm -r ~/.config/nvim
cp -r ./config/ags ~/.config
cp -r ./config/nvim ~/.config

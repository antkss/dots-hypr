#!/bin/bash
cd /home/$(whoami)
wget https://raw.githubusercontent.com/antkss/dots-hypr/master/.gdbnew.py 
echo "source /home/$(whoami)/.gdbnew.py" >> ~/.gdbinit

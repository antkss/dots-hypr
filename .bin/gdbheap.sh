#!/bin/bash
cd /home/$(whoami)
wget https://raw.githubusercontent.com/antkss/dots-hypr/master/.gdbnewheap.py 
echo "source /home/$(whoami)/.gdbnewheap.py" >> ~/.gdbinit

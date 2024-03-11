#!/usr/bin/fish
if status is-interactive
    # Commands to run in interactive sessions can go here
/home/as/.bin/bin/neofetchcheck
export PATH=$PATH:/home/as/.bin/bin
function fish_prompt
    set_color red;echo -n (fish basename $PWD) '🍎'
end
end

set -x PATH $PATH /sbin/

function ll
    ls -lh $argv
end
function fish_greeting                                            
	if test -z $DISPLAY 
		neofetch
	end
	set PATH /home/as/.bin/bin $PATH
	alias learn="cd /home/as/pwnable"
	alias intop="sudo intel_gpu_top"
	alias kcsc="cd /home/as/kcsc"
end 
function fish_prompt
	#generate 10 color from red
	set mycolors red yellow green blue white cyan
	set ran (random 1 6)
	set path (pwd | rev | cut -d/ -f1-3 | rev)
	echo (set_color blue)"$path"
	echo (set_color $mycolors[$ran])"shell@~🍎 "
end

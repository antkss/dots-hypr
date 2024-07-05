set -x PATH $PATH /sbin/

function ll
    ls -lh $argv
end
function fish_greeting                                            
	if test -z $DISPLAY 
		fastfetch
	end
	set PATH /home/as/.bin/bin:/home/as/cac/ghidra_11.0_PUBLIC/jre/bin $PATH
	alias learn="cd /home/as/pwnable"
	alias intop="sudo intel_gpu_top"
	alias kcsc="cd /home/as/kcsc"
end 
function fish_prompt
	#generate 10 color from red
	set mycolors red yellow green blue white cyan
	set ran (random 1 6)
	set path (pwd | rev | cut -d/ -f1-3 | rev)
	echo "[ " (set_color blue)"$path" (set_color reset)" ]"
	echo (set_color $mycolors[$ran])"🍎 >> "
end
function man --wraps man --description 'Format and display manual pages'
    set -q man_blink; and set -l blink (set_color $man_blink); or set -l blink (set_color -o red)
    set -q man_bold; and set -l bold (set_color $man_bold); or set -l bold (set_color -o 5fafd7)
    set -q man_standout; and set -l standout (set_color $man_standout); or set -l standout (set_color 949494)
    set -q man_underline; and set -l underline (set_color $man_underline); or set -l underline (set_color -u afafd7)

    set -l end (printf "\e[0m")

    set -lx LESS_TERMCAP_mb $blink
    set -lx LESS_TERMCAP_md $bold
    set -lx LESS_TERMCAP_me $end
    set -lx LESS_TERMCAP_so $standout
    set -lx LESS_TERMCAP_se $end
    set -lx LESS_TERMCAP_us $underline
    set -lx LESS_TERMCAP_ue $end
    set -lx LESS '-R -s'

    set -lx GROFF_NO_SGR yes # fedora

    set -lx MANPATH (string join : $MANPATH)
    if test -z "$MANPATH"
        type -q manpath
        and set MANPATH (command manpath)
    end

    # Check data dir for Fish 2.x compatibility
    set -l fish_data_dir
    if set -q __fish_data_dir
        set fish_data_dir $__fish_data_dir
    else
        set fish_data_dir $__fish_datadir
    end

    set -l fish_manpath (dirname $fish_data_dir)/fish/man
    if test -d "$fish_manpath" -a -n "$MANPATH"
        set MANPATH "$fish_manpath":$MANPATH
        command man $argv
        return
    end
    command man $argv
end

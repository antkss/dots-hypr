#!/bin/bash
if [[ -d ~/.cache/dots-hypr ]]; then
	cd ~/.cache/dots-hypr
	git pull
	curl "https://raw.githubusercontent.com/antkss/dots-hypr/master/up.sh" | bash
else
	git clone https://github.com/antkss/dots-hypr ~/.cache/dots-hypr
	curl "https://raw.githubusercontent.com/antkss/dots-hypr/master/up.sh" | bash
fi

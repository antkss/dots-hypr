#!/usr/bin/bash
gcc play.c -o play -lSDL2 -lSDL2_mixer -no-pie -fno-stack-protector -Wl,-z,norelro

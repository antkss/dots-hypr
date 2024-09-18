
#include <sys/socket.h>
#include <sys/un.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_mixer.h>
#define BUFFER_SIZE 1024
int play(char* path) {
    // Initialize SDL and SDL_mixer
    if (SDL_Init(SDL_INIT_AUDIO) < 0) {
        printf("Failed to initialize SDL: %s\n", SDL_GetError());
        return -1;
    }
    
    if (Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 2048) < 0) {
        printf("Failed to initialize SDL_mixer: %s\n", Mix_GetError());
        SDL_Quit();
        return -1;
    }

    // Load the audio file (ensure it's in a supported format like WAV or MP3)
    Mix_Music* music = Mix_LoadMUS(path);
    if (!music) {
        printf("Failed to load audio: %s\n", Mix_GetError());
        Mix_CloseAudio();
        SDL_Quit();
        return -1;
    }

    // Play the audio file
    Mix_PlayMusic(music, 1);

    // Wait until the audio finishes playing
    while(Mix_PlayingMusic()){

    }
    

    // Clean up
    Mix_FreeMusic(music);
    Mix_CloseAudio();
    SDL_Quit();

    return 0;
}
int main(int argc, char *argv[]) {
    if (argc != 2) {
	    printf("Usage: %s <audio_file>\n", argv[0]);
	    return 1;
    }
    play(argv[1]);
    return 0;
}


#include <sys/socket.h>
#include <sys/un.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_mixer.h>
#include <pthread.h>
#include <signal.h>
#include <sys/wait.h>
#define BUFFER_SIZE 1024


#include <SDL2/SDL.h>
#include <SDL2/SDL_mixer.h>
#include <stdio.h>

int play(char* path) {
    // Initialize SDL audio subsystem
    if (SDL_Init(SDL_INIT_AUDIO) < 0) {
        printf("SDL_Init Error: %s\n", SDL_GetError());
        return 1;
    }

    // Open audio device with desired settings
    if (Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 2048) < 0) {
        printf("Mix_OpenAudio Error: %s\n", Mix_GetError());
        SDL_Quit();
        return 1;
    }

    // Load the sound effect
    Mix_Chunk* sound = Mix_LoadWAV(path);
    if (sound == NULL) {
        printf("Mix_LoadWAV Error: %s\n", Mix_GetError());
        Mix_CloseAudio();
        SDL_Quit();
        return 1;
    }

    // Set volume to 50% (volume level is between 0 and 128)
    Mix_Volume(-1, 64);  // Set volume to 50% for all channels (-1 for all channels)

    // Play the sound effect on any available channel
    // 
    int channel = Mix_PlayChannel(-1, sound, 0);
    if ( channel == -1) {
        printf("Mix_PlayChannel Error: %s\n", Mix_GetError());
        Mix_FreeChunk(sound);
        Mix_CloseAudio();
        SDL_Quit();
        return 1;
    }
    while(Mix_Playing(channel)){
    };
    // Clean up
    Mix_FreeChunk(sound);  // Free the sound effect resource
    Mix_CloseAudio();      // Close audio device
    SDL_Quit();            // Quit SDL

    return 0;
}

void play2(char* path) {
    // Initialize SDL and SDL_mixer
    if (SDL_Init(SDL_INIT_AUDIO) < 0) {
        printf("Failed to initialize SDL: %s\n", SDL_GetError());
        return;
    }
    
    if (Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 2048) < 0) {
        printf("Failed to initialize SDL_mixer: %s\n", Mix_GetError());
        SDL_Quit();
        return;
    }

    // Load the audio file (ensure it's in a supported format like WAV or MP3)
    Mix_Music* music = Mix_LoadMUS(path);
    if (!music) {
        printf("Failed to load audio: %s\n", Mix_GetError());
        Mix_CloseAudio();
        SDL_Quit();
        return;
    }

    // Play the audio file
    Mix_PlayMusic(music, 1);

    // Wait until the audio finishes playing
    while(Mix_PlayingMusic()) {
        // Keep waiting
    };

    // Clean up
    Mix_FreeMusic(music);
    Mix_CloseAudio();
    SDL_Quit();
}

void playing(char* command) {
    char home[256] = {};
    snprintf(home, sizeof(home), "%s/.config/hypr/sound/", getenv("HOME"));
    if (command) {
        if (strcmp(command, "openwindow") == 0) {
            strcat(home, "add.wav");
            play(home);
        } else if (strcmp(command, "closewindow") == 0) {
            strcat(home, "remove.wav");
            play(home);
        } else if (strcmp(command, "fullscreen") == 0) {
            strcat(home, "fullscreen.wav");
            play(home);
        } else if (strcmp(command, "workspace") == 0 || strcmp(command, "workspacev2") == 0) {
            strcat(home, "change_workspace.wav");
            play(home);
        } else if (strcmp(command, "changefloatingmode") == 0) {
            strcat(home, "popup.wav");
            play(home);
        }
        kill(getpid(), SIGUSR1);
    }
}

void sigchld_handler(int signo) {
    // Reap all terminated children
    while (waitpid(-1, NULL, WNOHANG) > 0);
}

int main() {
    int sockfd;
    struct sockaddr_un addr;
    char buffer[BUFFER_SIZE];
    ssize_t bytes_received;
    
    // Set up the signal handler for SIGCHLD
    struct sigaction sa;
    sa.sa_handler = sigchld_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = SA_RESTART;
    if (sigaction(SIGCHLD, &sa, NULL) == -1) {
        perror("sigaction");
        exit(EXIT_FAILURE);
    }

    // Get the socket path from environment variables
    char *socket_path = getenv("XDG_RUNTIME_DIR");
    if (socket_path == NULL) {
        perror("XDG_RUNTIME_DIR not set");
        exit(EXIT_FAILURE);
    }

    char full_socket_path[256];
    snprintf(full_socket_path, sizeof(full_socket_path), "%s/hypr/%s/.socket2.sock",
             socket_path, getenv("HYPRLAND_INSTANCE_SIGNATURE"));

    // Create the socket
    if ((sockfd = socket(AF_UNIX, SOCK_STREAM, 0)) == -1) {
        perror("socket error");
        exit(EXIT_FAILURE);
    }

    // Prepare the socket address
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, full_socket_path, sizeof(addr.sun_path) - 1);

    // Connect to the socket
    if (connect(sockfd, (struct sockaddr*)&addr, sizeof(addr)) == -1) {
        perror("connect error");
        close(sockfd);
        exit(EXIT_FAILURE);
    }

    // Receive data from the socket
    while ((bytes_received = recv(sockfd, buffer, sizeof(buffer) - 1, 0)) > 0) {
        buffer[bytes_received] = '\0'; // Null-terminate the buffer
        char* command = strtok(buffer, ">>");
        if (!fork()) {
            playing(command);
            exit(0); // Ensure the child process exits after playing the sound
        }
    }

    // Close the socket
    close(sockfd);
    return 0;
}

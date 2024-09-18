
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
    };
    

    // Clean up
    Mix_FreeMusic(music);
    Mix_CloseAudio();
    SDL_Quit();

    return 0;
}
int main() {
    int sockfd;
    struct sockaddr_un addr;
    char buffer[BUFFER_SIZE];
    ssize_t bytes_received;
    
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

        // Tokenize the received data
        char* command = strtok(buffer, ">>");
	// printf("Command: %s\n", command);

        // Get the home directory and prepare the full path
        char home[256];
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
            }else if (strcmp(command,"workspace")==0){
		strcat(home,"change_workspace.wav");
		play(home);
	    }
        }
    }
    // Close the socket
    close(sockfd);
    return 0;
}


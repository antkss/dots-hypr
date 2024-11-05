
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
void play(char* path) {
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
    while(Mix_PlayingMusic()){

    //wating function in SDL
	SDL_Delay(1000);

    };
    

    // Clean up
    Mix_FreeMusic(music);
    Mix_CloseAudio();
    SDL_Quit();
    return;

}
void playing(char* path){
    play(path);
    kill(getpid(), SIGUSR1);
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
    while (1) {
	bytes_received = recv(sockfd, buffer, sizeof(buffer) - 1, 0);
        buffer[bytes_received] = '\0'; // Null-terminate the buffer
        char* command = strtok(buffer, ">>");
        char home[256] = {};
        snprintf(home, sizeof(home), "%s/.config/hypr/sound/", getenv("HOME"));
	// printf("%s\n",command);
	
        // if (command) {
	if (strcmp(command, "openwindow") == 0) {
	    strcat(home, "add.wav");
	} else if (strcmp(command, "closewindow") == 0) {
	    strcat(home, "remove.wav");
	} else if (strcmp(command, "fullscreen") == 0) {
	    strcat(home, "fullscreen.wav");
	}
	// else if (strcmp(command,"workspace")==0 || strcmp(command,"workspacev2")==0) {
	//     strcat(home,"change_workspace.wav");
	// }
	else if(strcmp(command,"changefloatingmode") ==0){
	    strcat(home,"popup.wav");
	}else{
	    continue;
	}
        // }
	if(!fork())
	{
	    playing(home);
	    exit(0);
	}


    }
    // Close the socket
    close(sockfd);
    return 0;
}


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

#define SOCKET_PATH "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
// #define MESSAGE "Hello, Server!"

int main() {
    int client_fd;
    struct sockaddr_un addr;
    char* env1 = getenv("XDG_RUNTIME_DIR");
    char* env2 = getenv("HYPRLAND_INSTANCE_SIGNATURE");
    char* socketpath = (char*)malloc(strlen(env1)+strlen(env2)+20+0x40);
    sprintf(socketpath,"%s/hypr/%s/.socket2.sock",env1,env2);
    char* message = (char*)malloc(0x34);
    // Create a UNIX socket
    client_fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (client_fd == -1) {
        perror("socket error");
        exit(EXIT_FAILURE);
    }

    // Set address family and path
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, socketpath, sizeof(addr.sun_path) - 1);

    // Connect to the server
    if (connect(client_fd, (struct sockaddr*)&addr, sizeof(addr)) == -1) {
        perror("connect error");
        close(client_fd);
        exit(EXIT_FAILURE);
    }
    if(!fork()){
	system("killall wl-paste;wl-paste --type text --watch cliphist store | wl-paste --type image --watch cliphist store");
    }else{
	while(1){
	    if (read(client_fd, message, 0x34) == -1) {
		perror("read error");
		close(client_fd);
		exit(EXIT_FAILURE);
	    }
	    message = strtok(message,">>");
	    if(!strcmp(message,"activewindow"))
	    {
		system("cliphist list | cliphist decode | wl-copy");
	    }
	    
	}
    }

    // Send a message to the server
    // if (write(client_fd, MESSAGE, strlen(MESSAGE)) == -1) {
    //     perror("write error");
    //     close(client_fd);
    //     exit(EXIT_FAILURE);
    // }

    // printf("Message sent: %s\n", MESSAGE);

    // Close socket
    close(client_fd);

    return 0;
}

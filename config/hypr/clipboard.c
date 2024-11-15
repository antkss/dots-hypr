#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/file.h>
#include <signal.h>

#define SOCKET_PATH "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
// #define MESSAGE "Hello, Server!"

#define LOCKFILE "/tmp/hyprclip.lock" 
int lock_fd;  // File descriptor for the lock file
struct flock lock;  // Lock structure

// Signal handler to cleanup lock file when the program is killed
void cleanup_lock(int signum) {
    printf("Cleaning up lock and exiting...\n");
    
    // Release the lock before exiting
    lock.l_type = F_UNLCK;
    fcntl(lock_fd, F_SETLK, &lock);
    
    // Optionally, remove the lock file
    unlink(LOCKFILE);
    
    close(lock_fd);  // Close the lock file descriptor
    exit(0);
}
int main() {

    // Open the lock file or create it if it doesn't exist
    lock_fd = open(LOCKFILE, O_CREAT | O_RDWR, 0666);
    if (lock_fd == -1) {
        perror("Failed to open lock file");
        exit(EXIT_FAILURE);
    }

    // Set up the lock structure for an exclusive lock
    lock.l_type = F_WRLCK;  // Exclusive lock
    lock.l_whence = SEEK_SET;
    lock.l_start = 0;
    lock.l_len = 0;  // Lock the entire file

    // Set up the signal handler for cleanup
    signal(SIGINT, cleanup_lock);  // Handle Ctrl+C (SIGINT)
    signal(SIGTERM, cleanup_lock); // Handle kill (SIGTERM)
    signal(SIGQUIT, cleanup_lock); // Handle quit (SIGQUIT)

    // Try to acquire the lock
    if (fcntl(lock_fd, F_SETLK, &lock) == -1) {
        perror("Failed to acquire lock");
        close(lock_fd);
        exit(EXIT_FAILURE);
    }
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
    cleanup_lock(0);

    return 0;
}

#include <iostream>
#include <cstring>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <signal.h>

#define PORT 8080
#define BUFFER_SIZE 1024
#define MSG_KEY 1234

struct Message {
    long mtype;
    char mtext[BUFFER_SIZE];
};

int msgid;

void handleSignal(int sig) {
    if (sig == SIGINT) {
        std::cout << "Received SIGINT, shutting down..." << std::endl;
        msgctl(msgid, IPC_RMID, NULL); // Remove the message queue
        exit(0);
    }
}

int main() {
    int server_fd, new_socket;
    struct sockaddr_in address;
    char buffer[BUFFER_SIZE] = {0};

    // Create message queue
    msgid = msgget(MSG_KEY, 0666 | IPC_CREAT);
    if (msgid < 0) {
        perror("msgget");
        return 1;
    }

    // Setup signal handler
    signal(SIGINT, handleSignal);

    // Create socket
    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("socket failed");
        return 1;
    }

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(PORT);

    // Bind the socket
    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        perror("bind failed");
        return 1;
    }

    // Listen for incoming connections
    if (listen(server_fd, 3) < 0) {
        perror("listen");
        return 1;
    }

    std::cout << "Server listening on port " << PORT << "..." << std::endl;

    while (true) {
        if ((new_socket = accept(server_fd, NULL, NULL)) < 0) {
            perror("accept");
            continue;
        }

        // Read data from the client
        int bytes_read = read(new_socket, buffer, BUFFER_SIZE);
        if (bytes_read > 0) {
            buffer[bytes_read] = '\0'; // Null-terminate the buffer

            // Prepare the message to send to workers
            Message msg;
            msg.mtype = 1;
            strncpy(msg.mtext, buffer, BUFFER_SIZE);

            // Send the message to the queue
            if (msgsnd(msgid, &msg, strlen(msg.mtext) + 1, 0) < 0) {
                perror("msgsnd");
            }
        }

        close(new_socket);
    }

    close(server_fd);
    return 0;
}

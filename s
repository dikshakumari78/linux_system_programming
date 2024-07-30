#include <iostream>
#include <thread>
#include <vector>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <cstring>
#include <sys/ipc.h>
#include <sys/msg.h>

#define PORT 8080

struct Message {
    long mtype;
    char mtext[1024];
};

void dataReceiver(int clientSocket, int msgQueueId) {
    char buffer[1024];
    while (true) {
        ssize_t bytesRead = read(clientSocket, buffer, sizeof(buffer) - 1);
        if (bytesRead <= 0) break;
        buffer[bytesRead] = '\0';

        Message msg;
        msg.mtype = 1;  // Message type
        strncpy(msg.mtext, buffer, sizeof(msg.mtext));

        if (msgsnd(msgQueueId, &msg, sizeof(msg.mtext), 0) == -1) {
            std::cerr << "Failed to send message" << std::endl;
        }
    }
    close(clientSocket);
}

void startServer(int msgQueueId) {
    int serverFd = socket(AF_INET, SOCK_STREAM, 0);
    struct sockaddr_in address;
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(PORT);

    bind(serverFd, (struct sockaddr *)&address, sizeof(address));
    listen(serverFd, 3);

    while (true) {
        int clientSocket = accept(serverFd, NULL, NULL);
        std::thread(dataReceiver, clientSocket, msgQueueId).detach();
    }
}

int main() {
    key_t key = ftok("data_ingestion", 65);
    int msgQueueId = msgget(key, 0666 | IPC_CREAT);

    startServer(msgQueueId);

    return 0;
}

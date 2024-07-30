#include <iostream>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <sys/types.h>
#include <cstring>
#include <unistd.h>
#include <signal.h>

#define BUFFER_SIZE 1024
#define MSG_KEY 1234

struct Message {
    long mtype;
    char mtext[BUFFER_SIZE];
};

void handleSignal(int sig) {
    if (sig == SIGINT) {
        std::cout << "Worker received SIGINT, shutting down..." << std::endl;
        exit(0);
    }
}

int main() {
    int msgid;
    Message msg;
    
    // Get message queue
    msgid = msgget(MSG_KEY, 0666 | IPC_CREAT);
    if (msgid < 0) {
        perror("msgget");
        return 1;
    }

    // Setup signal handler
    signal(SIGINT, handleSignal);

    while (true) {
        // Receive message from the queue
        if (msgrcv(msgid, &msg, sizeof(msg.mtext), 1, 0) < 0) {
            perror("msgrcv");
            continue;
        }

        // Process the message
        std::cout << "Worker received message: " << msg.mtext << std::endl;
    }

    return 0;
}

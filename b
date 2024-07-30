#include <iostream>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <cstring>

#define BUFFER_SIZE 1024

int main() {
    int pipefd[2]; // Array to hold the read and write file descriptors
    pid_t pid;
    char buffer[BUFFER_SIZE];

    // Create the pipe
    if (pipe(pipefd) == -1) {
        perror("pipe");
        return 1;
    }

    // Fork the process
    pid = fork();
    if (pid < 0) {
        perror("fork");
        return 1;
    }

    if (pid == 0) { // Child process
        close(pipefd[1]); // Close the write end of the pipe
        read(pipefd[0], buffer, BUFFER_SIZE);
        std::cout << "Child received message: " << buffer << std::endl;
        close(pipefd[0]);
        _exit(0);
    } else { // Parent process
        close(pipefd[0]); // Close the read end of the pipe
        const char *message = "Hello from parent";
        write(pipefd[1], message, strlen(message) + 1);
        close(pipefd[1]);
        wait(NULL); // Wait for child process to finish
    }

    return 0;
}






#include <iostream>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <unistd.h>
#include <sys/types.h>
#include <cstring>
#include <cstdlib>
#include <sys/wait.h>

#define MSG_SIZE 1024

struct Message {
    long mtype;
    char mtext[MSG_SIZE];
};

int main() {
    key_t key = ftok("ipc_message_queue", 65);
    int msgid = msgget(key, 0666 | IPC_CREAT);
    if (msgid < 0) {
        perror("msgget");
        return 1;
    }

    pid_t pid;
    Message msg;

    // Fork the process
    pid = fork();
    if (pid < 0) {
        perror("fork");
        return 1;
    }

    if (pid == 0) { // Child process
        msgrcv(msgid, &msg, sizeof(msg.mtext), 1, 0);
        std::cout << "Child received message: " << msg.mtext << std::endl;
        msgctl(msgid, IPC_RMID, NULL); // Remove the message queue
        _exit(0);
    } else { // Parent process
        msg.mtype = 1;
        strcpy(msg.mtext, "Hello from parent");
        msgsnd(msgid, &msg, strlen(msg.mtext) + 1, 0);
        wait(NULL); // Wait for child process to finish
    }

    return 0;
}



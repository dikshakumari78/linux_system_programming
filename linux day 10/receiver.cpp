#include <iostream>
#include <mqueue.h>
#include <cstring>
#include <cstdlib>
#include <cerrno>
#include <cstdio>

#define QUEUE_NAME "/test_queue"
#define MAX_SIZE 1024
#define MSG_STOP "exit"

int main() {
    mqd_t mq;
    struct mq_attr attr;
    char buffer[MAX_SIZE];

    // Initialize the queue attributes
    attr.mq_flags = 0;
    attr.mq_maxmsg = 10;
    attr.mq_msgsize = MAX_SIZE;
    attr.mq_curmsgs = 0;

    // Create the message queue
    mq = mq_open(QUEUE_NAME, O_CREAT | O_WRONLY, 0644, &attr);
    if (mq == -1) {
        std::cerr << "Error creating queue: " << strerror(errno) << std::endl;
        exit(1);
    }

    std::cout << "Enter a message: ";
    std::cin.getline(buffer, MAX_SIZE);

    // Send the message
    if (mq_send(mq, buffer, strlen(buffer) + 1, 0) == -1) {
        std::cerr << "Error sending message: " << strerror(errno) << std::endl;
        exit(1);
    }

    std::cout << "Message sent: " << buffer << std::endl;

    // Close the message queue
    mq_close(mq);

    return 0;
}

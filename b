#include <iostream>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <unistd.h>
#include <cstring>
#include <csignal>

struct Message {
    long mtype;
    char mtext[1024];
};

void signalHandler(int signum) {
    std::cout << "Worker process terminated" << std::endl;
    exit(signum);
}

void processData(int msgQueueId) {
    Message msg;
    while (true) {
        if (msgrcv(msgQueueId, &msg, sizeof(msg.mtext), 1, 0) != -1) {
            std::cout << "Processing data: " << msg.mtext << std::endl;
            // Data processing logic here
        } else {
            std::cerr << "Failed to receive message" << std::endl;
        }
    }
}

int main() {
    signal(SIGTERM, signalHandler);
    signal(SIGINT, signalHandler);

    key_t key = ftok("data_ingestion", 65);
    int msgQueueId = msgget(key, 0666 | IPC_CREAT);

    processData(msgQueueId);

    return 0;
}
coordinator
#include <iostream>
#include <vector>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

void manageWorkers(int numWorkers) {
    std::vector<pid_t> workers;

    for (int i = 0; i < numWorkers; ++i) {
        pid_t pid = fork();
        if (pid == 0) {
            execl("./worker", "worker", NULL); // Assumes worker is compiled as "worker"
            exit(1);
        } else if (pid > 0) {
            workers.push_back(pid);
        }
    }

    while (true) {
        int status;
        pid_t pid = wait(&status);
        if (pid > 0) {
            std::cout << "Worker " << pid << " terminated, restarting..." << std::endl;
            pid_t newPid = fork();
            if (newPid == 0) {
                execl("./worker", "worker", NULL);
                exit(1);
            } else {
                workers.push_back(newPid);
            }
        }
    }
}

int main() {
    int numWorkers = 4; // Number of worker processes
    manageWorkers(numWorkers);
    return 0;
}

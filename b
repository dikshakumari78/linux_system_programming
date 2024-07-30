#include <iostream>
#include <thread>
#include <vector>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <cstring>

#define PORT 8080

void dataReceiver(int clientSocket) {
    char buffer[1024];
    while (true) {
        ssize_t bytesRead = read(clientSocket, buffer, sizeof(buffer) - 1);
        if (bytesRead <= 0) break;
        buffer[bytesRead] = '\0';
        std::cout << "Data received: " << buffer << std::endl;
        // Here you would typically send the data to worker processes or IPC mechanism
    }
    close(clientSocket);
}

void startServer() {
    int serverFd = socket(AF_INET, SOCK_STREAM, 0);
    struct sockaddr_in address;
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(PORT);

    bind(serverFd, (struct sockaddr *)&address, sizeof(address));
    listen(serverFd, 3);

    while (true) {
        int clientSocket = accept(serverFd, NULL, NULL);
        std::thread(dataReceiver, clientSocket).detach();
    }
}

int main() {
    startServer();
    return 0;
}

#include <iostream>
#include <unistd.h>

void processData(const std::string& data) {
    std::cout << "Processing data: " << data << std::endl;
}

int main() {
    std::string data;
    while (true) {
        // Replace with IPC or socket read mechanism
        data = "Sample Data"; // Placeholder for actual data
        processData(data);
    }
    return 0;
}
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
            // Restart worker if it crashes
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

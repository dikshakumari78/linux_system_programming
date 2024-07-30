#include <iostream>
#include <csignal>
#include <unistd.h>

void handleSIGINT(int signum) {
    std::cout << "Caught signal SIGINT (" << signum << "). Terminating gracefully." << std::endl;
    exit(signum);
}
void handleSIGTERM(int signum) {
    std::cout << "Caught signal SIGTERM (" << signum << "). Terminating gracefully." << std::endl;
    exit(signum);
}

int main() {
    signal(SIGINT, handleSIGINT);
    signal(SIGTERM, handleSIGTERM);
    std::cout << "Program running. Press Ctrl+C to send SIGINT or use 'kill -TERM <pid>' to send SIGTERM." << std::endl;
    while (true) {
        sleep(1); 
    }

    return 0;
}


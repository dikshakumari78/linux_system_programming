#include <iostream>
#include <unistd.h>
#include <signal.h>
#include <sys/wait.h>
#include <cstring>

// Signal handler
void handle_signal(int signal) {
    std::cout << "Signal " << signal << " received by process " << getpid() << std::endl;
}

int main() {
    // Set up signal handlers
    signal(SIGINT, handle_signal);  // Handle Ctrl+C
    signal(SIGTERM, handle_signal); // Handle termination signal

    // Pipe file descriptors
    int pipefd[2];
    if (pipe(pipefd) == -1) {
        perror("pipe");
        return 1;
    }

    pid_t pid = fork();
    if (pid == -1) {
        perror("fork");
        return 1;
    }

    if (pid == 0) { // Child process
        close(pipefd[1]); // Close the write end of the pipe

        char buffer[128];
        ssize_t count;
        while ((count = read(pipefd[0], buffer, sizeof(buffer) - 1)) > 0) {
            buffer[count] = '\0';
            std::cout << "Child received: " << buffer << std::endl;
        }

        close(pipefd[0]); // Close the read end of the pipe
        _exit(0);

    } else { // Parent process
        close(pipefd[0]); // Close the read end of the pipe

        const char* message = "Hello from parent process!";
        write(pipefd[1], message, strlen(message));

        close(pipefd[1]); // Close the write end of the pipe

        // Wait for child to finish
        wait(NULL);
    }

    return 0;
}

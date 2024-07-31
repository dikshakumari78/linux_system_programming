#include <iostream>
#include <unistd.h>
#include <signal.h>
#include <sys/wait.h>
#include <cstring>

int pipefd1[2]; 
int pipefd2[2]; 

void parentSignalHandler(int sig) {
if (sig == SIGUSR1) {
 std::cout << "Parent received SIGUSR1" << std::endl;
} 
else if (sig == SIGCHLD) {
    int status;
    pid_t pid = wait(&status);
    std::cout << "Child process " << pid << " terminated" << std::endl;
    }
}

void childSignalHandler(int sig) {
    if (sig == SIGUSR1) {
        std::cout << "Child received SIGUSR1" << std::endl;
    }
}

int main() {
    if (pipe(pipefd1) == -1 || pipe(pipefd2) == -1) {
        perror("pipe");
        exit(EXIT_FAILURE);
    }
    pid_t pid = fork();

    if (pid == -1) {
        perror("fork");
        exit(EXIT_FAILURE);
    } else if (pid == 0) { 
        close(pipefd1[1]); 
        close(pipefd2[0]); 
        signal(SIGUSR1, childSignalHandler);
        char buffer[100];
        read(pipefd1[0], buffer, sizeof(buffer));
        std::cout << "Child received: " << buffer << std::endl;
        
        std::string result = "Child task completed";
        write(pipefd2[1], result.c_str(), result.length() + 1);
        close(pipefd1[0]);
        close(pipefd2[1]);
        kill(getppid(), SIGUSR1);

 exit(0);
} 
else { 
close(pipefd1[0]); 
close(pipefd2[1]); 
signal(SIGUSR1, parentSignalHandler);
signal(SIGCHLD, parentSignalHandler);
std::string message = "Hello from parent";
write(pipefd1[1], message.c_str(), message.length() + 1);
char buffer[100];
read(pipefd2[0], buffer, sizeof(buffer));
std::cout << "Parent received: " << buffer << std::endl;
close(pipefd1[1]);
close(pipefd2[0]);
wait(NULL);
std::cout << "Parent process exiting" << std::endl;
}
 return 0;
}

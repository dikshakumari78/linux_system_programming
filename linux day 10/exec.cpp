#include <iostream>
#include <unistd.h>

using namespace std;

int main() {
    char *args[] = {"/bin/ls", "-l", nullptr}; // Replace with your desired command and arguments

    // Replace the current process with the specified command
    if (execvp(args[0], args) == -1) {
        cerr << "Error executing command: " << errno << endl;
        return 1;
    }

    // This line will not be reached if execvp is successful
    cerr << "This should not be printed" << endl;
    return 0;
}

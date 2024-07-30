#include <iostream>
#include <unistd.h>
#include <cerrno>
#include <cstring>

using namespace std;

int main() {
    const char *args[] = {"/bin/ls", "-l", nullptr}; // Replace with your desired command and arguments

    // Replace the current process with the specified command
    if (execvp(args[0], const_cast<char * const *>(args)) == -1) {
        cerr << "Error executing command: " << strerror(errno) << endl;
        return 1;
    }

    // This line will not be reached if execvp is successful
    cerr << "This should not be printed" << endl;
    return 0;
}

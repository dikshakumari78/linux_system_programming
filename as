#include <iostream>
#include <fcntl.h>    
#include <unistd.h> 
#include <cstring>    
#include <cerrno>    

void handleError(const char* msg) {
    std::cerr << msg << ": " << strerror(errno) << std::endl;
}

int createFile(const char* filename) {
    int fd = open(filename, O_CREAT | O_WRONLY | O_TRUNC, 0644);
    if (fd == -1) {
        handleError("Error creating file");
    }
    return fd;
}

void writeFile(int fd, const char* content) {
    if (write(fd, content, strlen(content)) == -1) {
        handleError("Error writing to file");
    }
}

void readFile(const char* filename) {
    int fd = open(filename, O_RDONLY);
    if (fd == -1) {
        handleError("Error opening file for reading");
        return;
    }

    char buffer[1024];
    ssize_t bytesRead;
    while ((bytesRead = read(fd, buffer, sizeof(buffer) - 1)) > 0) {
        buffer[bytesRead] = '\0'; 
        std::cout << buffer;
    }
    if (bytesRead == -1) {
        handleError("Error reading from file");
    }
    close(fd);
}

void appendToFile(const char* filename, const char* content) {
    int fd = open(filename, O_WRONLY | O_APPEND);
    if (fd == -1) {
        handleError("Error opening file for appending");
        return;
    }

    if (write(fd, content, strlen(content)) == -1) {
        handleError("Error appending to file");
    }
    close(fd);
}

void deleteFile(const char* filename) {
    if (unlink(filename) == -1) {
        handleError("Error deleting file");
    }
}

int main() {
    const char* filename = "example.txt";
    const char* initialContent = "Hello, World!\n";
    const char* additionalContent = "Appended text.\n";

    int fd = createFile(filename);
    writeFile(fd, initialContent);
    close(fd);
    std::cout << "File contents:\n";
    readFile(filename);
    std::cout << std::endl;
    appendToFile(filename, additionalContent);
    std::cout << "Updated file contents:\n";
    readFile(filename);
    std::cout << std::endl;
    deleteFile(filename);

    return 0;
}

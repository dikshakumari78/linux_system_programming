#include <iostream>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <cstring>

const int PORT = 8080;
const char *SERVER_IP = "127.0.0.1"; // Replace with server IP if remote

int main() {
    int sock = 0, valread;
    struct sockaddr_in serv_addr;
    char buffer[1024] = {0};
    const char *hello = "Hello from client";

    // Create socket file descriptor
    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        printf("\n Socket creation error \n");
        return -1;
    }

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(PORT);

    // Convert IPv4 and IPv6 addresses from text to binary form
    if (inet_pton(AF_INET, SERVER_IP, &serv_addr.sin_addr) <= 0) {
        printf("\nInvalid address/ Address not supported \n");
        return -1;
    }

    // Connect to server
    if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
        printf("\nConnection Failed \n");
        return -1;
    }

    // Handle communication with server
    while (true) {
        memset(buffer, 0, sizeof(buffer));
        printf("Client (enter message): ");
        fgets(buffer, 1024, stdin);
        buffer[strcspn(buffer, "\n")] = 0; // Remove newline from fgets

        send(sock, buffer, strlen(buffer), 0);
        printf("Message sent to server\n");

        memset(buffer, 0, sizeof(buffer));
        valread = read(sock, buffer, 1024);
        printf("Server: %s\n", buffer);
    }

    return 0;
}

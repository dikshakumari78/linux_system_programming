#include <iostream>
#include <cstring>
#include <unistd.h>
#include <arpa/inet.h>

#define DEFAULT_PORT 8080
#define DEFAULT_BUFLEN 512

int main() {
    int clientSocket;
    struct sockaddr_in serverAddr;
    char sendbuf[DEFAULT_BUFLEN] = "Hello from client";
    char recvbuf[DEFAULT_BUFLEN];
    int recvbuflen = DEFAULT_BUFLEN;
    socklen_t serverAddrLen = sizeof(serverAddr);

    // Create a socket for the client
    clientSocket = socket(AF_INET, SOCK_DGRAM, 0);
    if (clientSocket < 0) {
        std::cerr << "Socket creation failed" << std::endl;
        return 1;
    }

    // Set up the sockaddr_in structure
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_port = htons(DEFAULT_PORT);
    inet_pton(AF_INET, "127.0.0.1", &serverAddr.sin_addr);

    // Send data to the server
    int sendLen = sendto(clientSocket, sendbuf, strlen(sendbuf), 0, (struct sockaddr*)&serverAddr, sizeof(serverAddr));
    if (sendLen < 0) {
        std::cerr << "sendto failed" << std::endl;
        close(clientSocket);
        return 1;
    }

    std::cout << "Sent: " << sendbuf << std::endl;

    // Receive data from the server
    int recvLen = recvfrom(clientSocket, recvbuf, recvbuflen, 0, (struct sockaddr*)&serverAddr, &serverAddrLen);
    if (recvLen < 0) {
        std::cerr << "recvfrom failed" << std::endl;
        close(clientSocket);
        return 1;
    }

    recvbuf[recvLen] = '\0'; // Null-terminate the received data
    std::cout << "Received: " << recvbuf << std::endl;

    // Cleanup
    close(clientSocket);
    return 0;
}

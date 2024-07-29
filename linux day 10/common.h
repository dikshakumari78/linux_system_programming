// common.h
#ifndef COMMON_H
#define COMMON_H

#include <semaphore.h>

#define SHARED_MEMORY_NAME "/my_shared_memory"
#define SEMAPHORE1_NAME "/sem1"
#define SEMAPHORE2_NAME "/sem2"
#define MAX_SIZE 1024

struct SharedMemory {
    char buffer[MAX_SIZE];
    bool process1_turn;
};

#endif

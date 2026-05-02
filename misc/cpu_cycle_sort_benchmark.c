#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>

// Function to get time in nanoseconds
uint64_t get_nanos() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (uint64_t)ts.tv_sec * 1000000000L + ts.tv_nsec;
}

void sort_16(int32_t *arr) {
    for (int i = 0; i < 15; i++) {
        for (int j = 0; j < 15 - i; j++) {
            if (arr[j] > arr[j + 1]) {
                int32_t temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
            }
        }
    }
}

int main() {
    int32_t data[16];
    for(int i=0; i<16; i++) data[i] = rand() % 100;

    // Estimate: M1 Firestorm cores run at approx 3.2 GHz
    // 1 cycle is roughly 0.3125 nanoseconds.
    
    uint64_t start = get_nanos();
    sort_16(data);
    uint64_t end = get_nanos();

    uint64_t diff = end - start;
    // Calculation: (nanoseconds * 3.2) to get approximate cycles
    double approx_cycles = diff * 3.2;

    printf("Time taken: %llu nanoseconds\n", diff);
    printf("Approximate M1 Cycles: %.2f\n", approx_cycles);

    return 0;
}
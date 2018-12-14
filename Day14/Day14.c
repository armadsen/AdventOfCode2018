#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

int checkForPart2(int8_t *scoreboard, int currentEndIndex, int8_t inputArray[], int inputArraySize) {
    if (currentEndIndex - inputArraySize < 0) { return -1; }
    int8_t *lastDigits = scoreboard + (currentEndIndex-inputArraySize);
    for (int i=0; i<inputArraySize; i++) {
        if (lastDigits[i] != inputArray[i]) { return -1; }
    }
    return currentEndIndex - inputArraySize;
}

int main(int argc, char *argv[]) {
    int scoreboardSize = 1024 * 1024;
    int8_t *scoreboard = malloc(scoreboardSize);
    scoreboard[0] = 3;
    scoreboard[1] = 7;
    int elf1 = 0;
    int elf2 = 1;
    int input = 825401;
    
    int8_t inputArray[] = {8, 2, 5, 4, 0, 1};
    int inputArraySize = sizeof(inputArray);
    
    int currentEndIndex = 2;
    bool gotPart1 = false;
    while (true) {
        int sum = scoreboard[elf1] + scoreboard[elf2];
        if (sum >= 10) {
            scoreboard[currentEndIndex++] = sum / 10;
            int part2 = checkForPart2(scoreboard, currentEndIndex, inputArray, inputArraySize);
            if (part2 >= 0) { printf("part 2: %i", part2); exit(0); }
        }
        scoreboard[currentEndIndex++] = sum % 10;
        int part2 = checkForPart2(scoreboard, currentEndIndex, inputArray, inputArraySize);
        if (part2 >= 0) { printf("part 2: %i", part2); exit(0); }
        
        elf1 = (elf1 + (scoreboard[elf1] + 1)) % currentEndIndex;
        elf2 = (elf2 + (scoreboard[elf2] + 1)) % currentEndIndex;
        
        if (!gotPart1 && currentEndIndex >= input + 10) {
            printf("part 1: ");
            for (int i=input; i<input+10; i++) {
                printf("%i", (int)scoreboard[i]);
            }
            printf("\n");
            gotPart1 = true;
        }

        if (currentEndIndex+2 >= scoreboardSize) {
            scoreboardSize += 1024 * 1024;
            scoreboard = realloc(scoreboard, scoreboardSize);
        }
    }
}
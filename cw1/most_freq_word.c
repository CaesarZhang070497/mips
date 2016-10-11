// =========================================================================
//
// Find most occuring word in a sentence
//
// Inf2C-CS Coursework 1. Task B
// OUTLINE code, to be completed as part of coursework.
//
// Boris Grot, Priyank Faldu
// October 11, 2016
//
// =========================================================================


// C Header files
#include <stdio.h>

#include <stdio.h>

void read_string(char* s, int size) { fgets(s, size, stdin); }

void print_char(char c)    { printf("%c", c); }   
void print_int(int num)    { printf("%d", num); }
void print_string(char* s) { printf("%s", s); }


// Maximum characters in an input sentence including terminating null character
#define MAX_CHARS 1001

// Maximum characters in a word including terminating null character
#define MAX_WORD_LENGTH 51

char input_sentence[MAX_CHARS];
char word[MAX_WORD_LENGTH];
int num_unique_words = 0;
int max_frequency = -1;
int num_words_with_max_frequency = 0;

int read_input(char* inp) {
    print_string("\ninput: ");
    read_string(input_sentence, MAX_CHARS);
}

void output(int unique_words, int max_freq, int num_words_w_max_freq, char* out) {
    print_string("output:\n");
    print_int(unique_words);
    print_string("\n");
    print_int(max_freq);
    print_string("\n");
    print_int(num_words_w_max_freq);
    print_string("\n");
    print_string(out);
    print_string("\n");
}

///////////////////////////////////////////////////////////////////////////////
//
// DO NOT MODIFY CODE ABOVE
//
///////////////////////////////////////////////////////////////////////////////

// ADD CUSTOM FUNCTIONS AND OTHER GLOBAL VARIABLES AS NEEDED

void process_input(char* inp) {
    // Populate following global variables
    // num_unique_words
    // max_frequency,
    // num_words_with_max_frequency
    // word
    
    // You may define more local variables here
    // and call custom functions from here
}

///////////////////////////////////////////////////////////////////////////////
//
// DO NOT MODIFY CODE BELOW
//
///////////////////////////////////////////////////////////////////////////////

int main() {

    while(1) {

        num_unique_words = 0;
        max_frequency = -1;
        num_words_with_max_frequency = 0;
        word[0] = '\0';

        read_input(input_sentence);

        process_input(input_sentence);

        output(num_unique_words, max_frequency, num_words_with_max_frequency, word);
    }
}

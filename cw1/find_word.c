// ==========================================================================
// Word Finder
// ==========================================================================
// Prints all words in a sentence

// Inf2C-CS Coursework 1. Task A 
// PROVIDED file, to be used as model for writing MIPS code.

// Boris Grot, Priyank Faldu
// October 11, 2016

//---------------------------------------------------------------------------
// C definitions for SPIM system calls
//---------------------------------------------------------------------------
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

void read_input(char* inp) {
    print_string("\ninput: ");
    read_string(input_sentence, MAX_CHARS);
}

void output(char* out) {
    print_string(out);
    print_string("\n");
}

int is_delimiting_char(char ch) {
    if ( ch == ' ') {
        return 1;
    } else if ( ch == ',') {
        return 1;
    } else if ( ch == '.') {
        return 1;
    } else if ( ch == '!') {
        return 1;
    } else if ( ch == '?') {
        return 1;
    } else if ( ch == '_') {
        return 1;
    } else if ( ch == '-') {
        return 1;
    } else if ( ch == '(') {
        return 1;
    } else if ( ch == ')') {
        return 1;
    } else if ( ch == '\n') { // Terminate the word if newline character found
        return 1;
    } else if ( ch == '\0') { // Terminate the word if null character found
        return 1;
    } else {
        return 0;
    }
}

// Global index that points to the next character to be processed in "input_sentence"
// Retains its value across function calls
int input_index = 0;
// Tracks if the input is processed completely
int end_of_sentence = 0;

int process_input(char* inp, char* out) {

    // This function processes character array pointed to by "inp".
    // It starts processing array from the location indexed by "input_index".
    // After processing, "out" stores the first word extracted from "inp" as a
    // null terminating string.
    // It returns 1 if the "inp" is processed completly and all the words are
    // extracted from it.

    // Points to the next empty location in "out"
    int char_index = 0;
    int is_delim_ch = 0;
    char cur_char = '\0';
    int word_found = 0;

    while( end_of_sentence == 0 && word_found == 0 ) {
        // This loop runs until end of sentence is encountered or a valid word is
        // extracted

        cur_char = inp[input_index];

        // Check if it is a delimiting character
        is_delim_ch = is_delimiting_char(cur_char);

        if ( is_delim_ch == 1 ) {

            if ( cur_char == '\n' ) {
                end_of_sentence = 1;
            }

            if ( char_index > 0 ) {
                // "out" has accumulated at least one character
                word_found = 1;
            } else {
                // Do nothing - Skip the delimiting character.
                // Control reaches here when "out" hasn't accumulated any
                // characters and delimiting character is encountered.
            }

        } else {
            // Not a delimiting charcter
            // Copy the current character to "out"
            out[char_index] = cur_char;

            // Point "char_index" to next empty character location
            char_index++;
        }

        // Current character is processed
        // Point "input_index" to the next character
        input_index++;
    }

    // Append the terminating character
    out[char_index] = '\0';
    return word_found;
}


int main() {

    int word_found = 0;

    while(1) {
        // Reset the input_index to start tracking new "input_sentence"
        input_index = 0;
        end_of_sentence = 0;

        read_input(input_sentence);

        print_string("output:\n");

        do {

            word_found = process_input(input_sentence, word);

            if ( word_found == 1 ) {
                output(word);
            }

        } while ( end_of_sentence != 1 );

    }

    return 0;
}

//---------------------------------------------------------------------------
// End of file
//---------------------------------------------------------------------------

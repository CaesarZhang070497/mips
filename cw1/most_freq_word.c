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

void read_input(char* inp) {
    print_string("\ninput: ");
    read_string(inp, MAX_CHARS);
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

/*
* C Implementaion of Find Most-Frequently Occuring Word.
* Comments provided to explain functions and general logic flow
* 
* By Aw Young Qingzhuo s1546138
*/

/*
* Function taken verbatim from find_word.c sample code
*/
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

/*
* Checks 2 words in char array for similarity.
* returns 0 if same, non-zero otherwise. does NOT indicate order of words.
* Modified implementation of strcmp, stops at any delimiter instead of \0
* Takes in 2 args which are pointers to start of words in string.
*/
int wordcmp(const char* s1, const char* s2) {
    while(!is_delimiting_char(*s1) && (*s1==*s2))
        s1++,s2++;
    if (is_delimiting_char(*s1) && is_delimiting_char(*s2))
        return 0;
    else 
        return 1;
}

/*
* Copies first delimiter delimited word from source into destination
* Destination is null terminated.
*/
char * wordcpy(char * destination, char * source) {
    int i = 0;
    while (!is_delimiting_char(*source)) {
        destination[i++] = *source++;
    }
    destination[i] = '\0';
    return destination;
}

/*
* Define our struct for storing word and occurance count
*/
typedef struct Word {
    char *word; // Pointer to start of word
    int count;  // Count of occurances
} Word;

/*
* Process input string to find:
* - num_unique_words
* - max_frequency
* - num_words_with_max_frequency
* - most common word
* More efficient implementation than naive implementation in find_word.c
*/
void process_input(char* inp) {
    int i; // for c90 compatibility (ironically this comment isn't compliant)
    // There can be maximum MAX_CHARS/2 words, when all words are 1 char long
    Word unique[MAX_CHARS/2];
    char *cur_char = inp;  // Pointer to current char we are processing
    int parsed = 0;        // Boolean var for if current word is already parsed
    while (*cur_char != '\0') {
        if (parsed || is_delimiting_char(*cur_char)) {
            // Skip to next unparsed word
            if (is_delimiting_char(*cur_char)) {
                parsed = 0;
            }
            cur_char++;
        } else {
            int is_unique = 1;
            // Check if word is repeated, if so increment counter for that word
            for (i = 0; i < num_unique_words; i++) {
                if (wordcmp(cur_char, unique[i].word) == 0) {
                    unique[i].count++;
                    is_unique = 0;
                    break;
                }
            }
            // If word is encountered first time, add it to the list of uniques
            if (is_unique) {
                unique[num_unique_words].word = cur_char;
                unique[num_unique_words].count = 1;
                num_unique_words++;
            }
            cur_char++;
            parsed = 1;  // Indicate that current word is parsed
        }
    }
    // Iterate through list of words to find max and count
    for (i = 0; i < num_unique_words; i++) {
        if (unique[i].count > max_frequency) {
            max_frequency = unique[i].count;
            wordcpy(word, unique[i].word);
            num_words_with_max_frequency = 1;
        } else if (unique[i].count == max_frequency) {
            num_words_with_max_frequency++;
        }
    }
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

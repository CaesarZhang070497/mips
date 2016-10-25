#=============================================================================|
# INF2C-CS Coursework 1                                                       |
# Task B: Find Most-Frequently Occurring Word                                 |
#=============================================================================|
# Qingzhuo Aw Young Pang s1546138                                             |
#                                                                             |
# Program functions identically to C program, however it is not a 1-to-1      |
# translation. Optimization and refactoring performed to reduce redundant     |
# variables (save registers) or instructions. Clarification and explanations  |
# in comments will be included whereever MIPS code differs from C counterpart.|
#                                                                             |
# Comments provided will be less detailed than for Task A, and will only      |
# explain program logic or deviations from C code. Assumption is made that    |
# the reader is well versed in C and MIPS assembly.                           |
#                                                                             |
# Program is meant to run on MARS but uses only SPIM instruction set due to   |
# restrictions set out by the assignment. As such, some parts of the program  |
# may seem unnecessarily verbose as we do not use MARS-only pseudoinstructions|
# We also 'lose' one register as $at used for pseudoinstructions is assembler |
# reserved. However this does not pose an issue for this task.                |
#                                                                             |
# File is formatted in the following manner:                                  |
# MIPS Instructions            # Detailed comments / explanations             | //Code in C
# Best viewed in editors with 80 cols (no C code) or 150 cols (with C code)   |
# ============================================================================|
        .data
                                # Constant strings for output                 |
input_str:      .asciiz "\ninput: "
output_str:     .asciiz "output:\n"
newline:        .asciiz "\n"
                                # Other global and allocate space for strings |
maxchars:       .word 1001      # #define MAX_CHARS 1001                      |
input_sentence: .space 1001
word:           .space 51
unique:         .space 1000     # mapping of word to count. sizeof = 8 bytes
num_unique_words:
                .word 1         # dummy values
max_frequency:  .word 1         # will be re-initialized
num_words_with_max_frequency: 
                .word 1
        .text
        .globl main             #
main:                           #                                             |int main() {
m_loop:                         #                                             |    while(1) {
        la $t0, num_unique_words
        sw $zero, 0($t0)        #                                             |        num_unique_words = 0;
        li $t1, -1
        la $t0, max_frequency
        sw $t1, 0($t0)          #                                             |        max_frequency = -1;
        la $t0, num_words_with_max_frequency
        sw $zero, 0($t0)        #                                             |        num_words_with_max_frequency = 0;
        la $t0, word
        sb $zero, 0($t0)        #                                             |        word[0] = '\0';
        la $a0, input_sentence  # provide &input_sentence[0] as arg           |
        jal read_input          # call read_input(input_sentence)             |        read_input(input_sentence);
        la $a0, input_sentence  # provide &input_sentence[0] as arg           |
        jal process_input       # call process_input(input_sentence)          |        process_input(input_sentence);
        la $a0, num_unique_words
        la $a1, max_frequency
        la $a2, num_words_with_max_frequency
        la $a3, word
        jal output              #                                             |        output(num_unique_words, max_frequency, num_words_with_max_frequency, word);
        j m_loop                #                                             |    }
                                #                                             |}
read_input:                     #                                             |void read_input(char* inp) {
        addi $sp, $sp, -4       # preserve $ra                                |
        sw $ra, 0($sp)
        move $t0, $a0           # store char* inp temporarily                 |
        li $v0, 4               # prepare print_string syscall                |
        la $a0, input_str       # load "\ninput: " as argument to syscall     |
        syscall                 # call print_string as syscall                |    print_string("\ninput: ");
        li $v0, 8               # prepare Read String syscall                 |
        move $a0, $t0           # load inp into $a0 arg for syscall           |
        la $a1, maxchars        # load MAX_CHARS into $a1 arg..               |
        syscall                 # call read_string as syscall                 |    read_string(input_sentence, MAX_CHARS);
        lw $ra, 0($sp)          # restore $ra                                 |
        addi $sp, $sp, 4
        jr $ra                  # implicit return                             |}

output:                         #                                             |void output(int unique_words, int max_freq, int num_words_w_max_freq, char* out) {
        sw $ra, -0x04($sp)      # preserve saved registers
        sw $s0, -0x08($sp)      # hex for better alignment
        sw $s1, -0x0c($sp)
        sw $s2, -0x10($sp)
        sw $s3, -0x14($sp)      
        addi $sp, $sp, -0x14
        lw $s0, 0($a0)          # store values in saved registers
        lw $s1, 0($a1)
        lw $s2, 0($a2)
        move $s3, $a3           # store pointer for word
        li $v0, 4             
        la $a0, output_str
        syscall                 #                                             |    print_string("output:\n");               
        li $v0, 1             
        move $a0, $s0
        syscall                 #                                             |    print_int(unique_words);               
        li $v0, 4
        la $a0, newline       
        syscall                 #                                             |    print_string("\n");                     
        li $v0, 1 
        move $a0, $s1
        syscall                 #                                             |    print_int(max_freq);               
        li $v0, 4
        la $a0, newline       
        syscall                 #                                             |    print_string("\n");                     
        li $v0, 1 
        move $a0, $s2
        syscall                 #                                             |    print_int(num_words_w_max_freq);               
        li $v0, 4
        la $a0, newline       
        syscall                 #                                             |    print_string("\n");                     
        li $v0, 4             
        move $a0, $s3
        syscall                 #                                             |    print_string(out);  
        li $v0, 4                   
        la $a0, newline       
        syscall                 #                                             |    print_string("\n");                    
        lw $ra, 0x10($sp)       # restore saved registers and $ra
        lw $s0, 0x0c($sp)       # hex for better alignment (again) 
        lw $s1, 0x08($sp)
        lw $s2, 0x04($sp)
        lw $s3, 0x00($sp)
        addi $sp, $sp, 0x14     # restore $sp
        jr $ra                  # implicit return                             | }

is_delimiting_char:             #                                             | int is_delimiting_char(char ch) {
        addi $sp, $sp, -4       # preserve $ra                                |
        sw $ra, 0($sp)
        li $t0, 0x00            # strictly following SPIM instruction set
        beq $a0, $t0, ret1      # NUL  #                                      |     if(delimiters) {
        li $t0, 0x0A
        beq $a0, $t0, ret1      # LF                                          |
        li $t0, 0x20
        beq $a0, $t0, ret1      # Space                                       |
        li $t0, 0x21
        beq $a0, $t0, ret1      # !                                           |
        li $t0, 0x28
        beq $a0, $t0, ret1      # (                                           |          ...
        li $t0, 0x29
        beq $a0, $t0, ret1      # )                                           |
        li $t0, 0x2C
        beq $a0, $t0, ret1      # ,                                           |
        li $t0, 0x2D
        beq $a0, $t0, ret1      # -                                           |
        li $t0, 0x2E
        beq $a0, $t0, ret1      # .                                           |          ...
        li $t0, 0x3F
        beq $a0, $t0, ret1      # ?                                           |
        li $t0, 0x5F
        beq $a0, $t0, ret1      # _                                           |
        li $v0, 0               #                                             |         return 1;
        j ret                   #                                             |     } else {
ret1:   li $v0, 1               #                                             |         return 0;
ret:    lw $ra, 0($sp)          # restore $ra                                 |     }
        addi $sp, $sp, 4
        jr $ra                  # return $v0                                  |
                                #                                             |}

wordcmp:                        #                                             |int wordcmp(const char* s1, const char* s2) {
        sw $ra, -0x04($sp)      # preserve saved registers
        sw $s0, -0x08($sp)      # hex for better alignment
        sw $s1, -0x0c($sp)
        sw $s2, -0x10($sp)
        addi $sp, $sp, -0x10
        move $s0, $a0           # s1
        move $s1, $a1           # s2
loop:   lb $a0, 0($s0)
        jal is_delimiting_char
        lb $t0, 0($s0)
        lb $t1, 0($s1)
        sne $t3, $t0, $t1       # *s1!=*s2
        or $t3, $t3, $v0        # is_delimiting_char(*s1) or *s1!=*s2
        bnez $t3, skip          # demorgans, is equivalent logic              |    while(!is_delimiting_char(*s1) && (*s1==*s2))
        addi $s0, $s0, 1        #                                             |        s1++,s2++;
        addi $s1, $s1, 1
        j loop
skip:   lb $a0, 0($s0)
        jal is_delimiting_char
        move $s2, $v0           # is_delimiting_char(*s1)
        lb $a0, 0($s1)
        jal is_delimiting_char
        and $s2, $s2, $v0       # is_delimiting_char(*s2)
        li $v0, 1
        beqz $s2, diff          #                                             |    if (is_delimiting_char(*s1) && is_delimiting_char(*s2))
        li $v0, 0               #                                             |        return 0;
diff:                           #                                             |    else
        lw $ra, 0x0c($sp)       #                                             |        return 1;
        lw $s0, 0x08($sp)
        lw $s1, 0x04($sp)
        lw $s2, 0x00($sp)
        addi $sp, $sp, 0x10     # restore $sp
        jr $ra                  #                                             |}

wordcpy:                        #                                             |char * wordcpy(char * destination, char * source) {
        sw $ra, -0x04($sp)      # preserve saved registers
        sw $s0, -0x08($sp)      # hex for better alignment
        sw $s1, -0x0c($sp)
        sw $s2, -0x10($sp)
        addi $sp, $sp, -0x10
        move $s0, $a0           # destination
        move $s1, $a1           # source
        move $s2, $a0           # destination (return) 
loop2:                          #                                             |    while (!is_delimiting_char(*source)) {
        lb $a0, 0($s1)
        jal is_delimiting_char
        bnez $v0, end2          # test while condition
        lb $t0, 0($s1)          #                                             |        destination[i++] = *source++;
        sb $t0, 0($s0)
        addi $s0, $s0, 1
        addi $s1, $s1, 1
        j loop2                 #                                             |    }
end2:   sb $zero, 0($s0)        #                                             |    destination[i] = '\0';
        move $v0, $s2           #                                             |    return destination;
        lw $ra, 0x0c($sp)
        lw $s0, 0x08($sp)
        lw $s1, 0x04($sp)
        lw $s2, 0x00($sp)
        addi $sp, $sp, 0x10     # restore $sp
        jr $ra                  #                                             |}
        
process_input:                  #                                             |void process_input(char* inp) {
        sw $ra, -0x04($sp)      # preserve saved registers
        sw $s0, -0x08($sp)      # hex for better alignment
        sw $s1, -0x0c($sp)
        sw $s2, -0x10($sp)
        sw $s3, -0x14($sp)      
        sw $s4, -0x18($sp)      # preserve $ra
        addi $sp, $sp, -0x18
        move $s0, $a0           # cur_char                                    |    char *cur_char = inp;  // Pointer to current char we are processing
        li $s1, 0               # parsed                                      |    int parsed = 0;        // Boolean var for if current word is already parsed
loop3:  lb $t0, 0($s0)          #                                             |    while (*cur_char != '\0') {
        beqz $t0, end3
        move $a0, $t0
        jal is_delimiting_char
        or $t1, $s1, $v0
        beqz $t1, parse         # hackish way, can prove                      |        if (parsed || is_delimiting_char(*cur_char)) {
        seq $s1, $v0, $zero     # correctness with truth table                |            if (is_delimiting_char(*cur_char)) parsed = 0;
        addi $s0, $s0, 1        #                                             |            cur_char++;
        j loop3                 #                                             |        } else {
parse:  li $s2, 1               # is unique                                   |            int is_unique = 1;
        li $s3, 0               # i = 0, loop variable initializer            |            for (i = 0; i < num_unique_words; i++) {
search: la $t0, num_unique_words
        lw $t0, 0($t0)
        bge $s3, $t0, searchd   # check for loop condition
        move $a0, $s0
        move $t0, $s3
        sll $t0, $t0, 3         # fast *= 8 (datatype is 8 bytes)
        la $s4, unique
        add $s4, $s4, $t0       # calculate &unique[i]
        lw $a1, 0($s4)          # first 4 bytes = pointer to word
        jal wordcmp
        bnez $v0, cont          #                                             |                if (wordcmp(cur_char, unique[i].word) == 0) {
        lw $t0, 4($s4)          # last 4 bytes = count of occurances
        addi $t0, $t0, 1        #                                             |                    unique[i].count++;
        sw $t0, 4($s4)
        li $s2, 0               #                                             |                    is_unique = 0;
        j searchd               # break out of loop                           |                    break;
cont:   addi $s3, $s3, 1        # increment loop variable                     |                 }
        j search                # jump back to loop start                     |            }
searchd:beqz $s2, not_uniq      # add new map entry if new word found         |            if (is_unique) {
        la $s4, unique
        la $t0, num_unique_words
        lw $t0, 0($t0)
        sll $t1, $t0, 3
        add $s4, $s4, $t1       # calculate &unique[num_unique_words]
        sw $s0, 0($s4)          #                                             |                unique[num_unique_words].word = cur_char;
        li $t1, 1
        sw $t1, 4($s4)          #                                             |                unique[num_unique_words].count = 1;
        addi $t1, $t0, 1
        la $t0, num_unique_words
        sw $t1, 0($t0)          #                                             |                num_unique_words++;
not_uniq:                       #                                             |            }
        addi $s0, $s0, 1        # increment cursor pointer                    |            cur_char++;
        li $s1, 1               # set word to parsed                          |            parsed = 1;  // Indicate that current word is parsed
        j loop3                 # continue while loop                         |        }
end3:                           #                                             |    }
        li $s3, 0               # iterate through list of uniq words          |    for (i = 0; i < num_unique_words; i++) {
count:  la $t0, num_unique_words
        lw $t0, 0($t0)
        bge $s3, $t0, countd    # check for loop condition
        move $t0, $s3           #                                             |
        sll $t0, $t0, 3         # fast *= 8
        la $s4, unique
        add $s4, $s4, $t0       # calculate &unique[i]
        lw $t0, 4($s4)
        la $t1, max_frequency
        lw $t2, 0($t1)
        blt $t0, $t2, cont2     # skip if less than max                       |        if (unique[i].count > max_frequency) {
        beq $t0, $t2, equal     # 
        sw $t0, 0($t1)          #                                             |            max_frequency = unique[i].count;
        la $a0, word
        lw $a1, 0($s4)
        jal wordcpy             #                                             |            wordcpy(word, unique[i].word);
        li $t0, 1
        la $t1, num_words_with_max_frequency
        sw $t0, 0($t1)          #                                             |            num_words_with_max_frequency = 1;
        j cont2
equal:                          # add to count if = max                       |}        else if (unique[i].count == max_frequency) {
        la $t1, num_words_with_max_frequency 
        lw $t0, 0($t1)                      
        addi $t0, $t0, 1
        sw $t0, 0($t1)          #                                             |            num_words_with_max_frequency++;
cont2:  addi $s3, $s3, 1        # increment loop variable                     |        }
        j count                 # continue for loop                           |    }
countd: lw $ra, 0x14($sp)       # restore saved registers and $ra
        lw $s0, 0x10($sp)       # hex for better alignment (again)
        lw $s1, 0x0c($sp)
        lw $s2, 0x08($sp)
        lw $s3, 0x04($sp)
        lw $s4, 0x00($sp)
        addi $sp, $sp, 0x18     # restore $sp
        jr $ra                  # end of procedure                            |}
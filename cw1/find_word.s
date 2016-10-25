#=============================================================================|
# INF2C-CS Coursework 1                                                       |
# Task A: Word Finder                                                         |
#=============================================================================|
# Qingzhuo Aw Young Pang s1546138                                             |
#                                                                             |
# Program functions identically to C program, however it is not a 1-to-1      |
# translation. Optimization and refactoring performed to reduce redundant     |
# variables (save registers) or instructions. Clarification and explanations  |
# in comments will be included whereever MIPS code differs from C counterpart.|
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
       # Constant strings for output                                          |
input_str:      .asciiz "\ninput: "
output_str:     .asciiz "output:\n"
newline:        .asciiz "\n"
       # Other constants and allocated space for strings                      |
maxchars:       .word 1001      # #define MAX_CHARS 1001                      |
input_sentence: .space 1001
word:           .space 51
input_index:    .word 1         # dummy values
end_of_sentence:.word 1         # will be reinitialized
        .text
        .globl main
main:                           # main reordered so always start at main      | int main() {
                                # redundant local temp variable.              |     int word_found = 0;
m_loop:                         #                                             |     while(1) {
        la $t0, input_index     #                                             |         input_index = 0;
        sw $zero, 0($t0)
        la $t0, end_of_sentence #                                             |         end_of_sentence = 0;
        sw $zero, 0($t0)
        la $a0, input_sentence  # provide &input_sentence[0] as arg           |
        jal read_input          # call read_input(input_sentence)             |         read_input(input_sentence);
        li $v0, 4               # prepare print_string syscall                |
        la $a0, output_str      # load "output:\n" as argument to syscall     |
        syscall                 # call print_string as syscall                |         print_string("output:\n");
m_inner:                        #                                             |         do {
        la $a0, input_sentence  # provide &input_sentence[0] as arg           |
        la $a1, word            # provide &word[0] as 2nd arg                 |
        jal process_input       # call process_input(input_sentence, word)    |             word_found = process_input(input_sentence, word);
        beqz $v0, m_inner_end   #                                             |             if ( word_found == 1 ) {
        la $a0, word            # provide &word[0] as arg to following call   |
        jal output              # call output(word)                           |                 output(word);
m_inner_end:                    #                                             |             }
        li $t0, 1               #                                             |
        la $t1, end_of_sentence #                                             |         end_of_sentence = 0;
        lw $t1, 0($t1)
        bne $t1, $t0, m_inner   #                                             |         } while ( end_of_sentence != 1 );
        j m_loop
                                # never reached, nop                          |      return 0;
                                #                                             | }

read_input:                     #                                             | void read_input(char* inp) {
        addi $sp, $sp, -4       # preserve $ra                                |
        sw $ra, 0($sp)
        move $t0, $a0           # store char* inp temporarily                 |
        li $v0, 4               # prepare print_string syscall                |
        la $a0, input_str       # load "\ninput: " as argument to syscall     |
        syscall                 # call print_string as syscall                |     print_string("\ninput: ");
        li $v0, 8               # prepare Read String syscall                 |
        move $a0, $t0           # load inp into $a0 arg for syscall           |
        la $a1, maxchars        # load MAX_CHARS into $a1 arg..               |
        syscall                 # call read_string as syscall                 |     read_string(input_sentence, MAX_CHARS);
        lw $ra, 0($sp)          # restore $ra                                 |
        addi $sp, $sp, 4
        jr $ra                  # implicit return                             | }

output:                         #                                             | void output(char* out) {
        addi $sp, $sp, -4       # preserve $ra                                |
        sw $ra, 0($sp)
        li $v0, 4               # prepare print_string syscall, out = $a0     |
        syscall                 # call print_string as syscall                |     print_string(out);
        la $a0, newline         # load "\n" as argument to syscall            |
        syscall                 # call print_string as syscall                |     print_string("\n");
        lw $ra, 0($sp)          # restore $ra                                 |
        addi $sp, $sp, 4
        jr $ra                  # implicit return                             | }

is_delimiting_char:             #                                             | int is_delimiting_char(char ch) {
        addi $sp, $sp, -4       # preserve $ra                                |
        sw $ra, 0($sp)
        li $t0, 0x00            # strictly following SPIM instruction set
        beq $a0, $t0, ret1      # NUL  #                                       |     if(delimiters) {
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
ret1:       li $v0, 1           #                                             |         return 0;
ret:        lw $ra, 0($sp)      # restore $ra                                 |     }
        addi $sp, $sp, 4
        jr $ra                  # return $v0                                  |
                                #                                             | }

process_input:                  #                                             | int process_input(char* input, char* out) {
        sw $ra, -0x04($sp)      # preserve saved registers
        sw $s0, -0x08($sp)      # hex for better alignment
        sw $s1, -0x0c($sp)
        sw $s2, -0x10($sp)
        sw $s3, -0x14($sp)
        addi $sp, $sp, -0x14
        move $s0, $a0           # store &inp[0]                               |
        move $s1, $a1           # store &char[0]                              |
        li $s2, 0               #                                             |     int char_index = 0;
                                # local temp variable is redundant            |     int is_delim_ch = 0;
                                # another temp var, compute on fly.           |     char cur_char = 0;
        li $s3, 0               #                                             |     int word_found = 0;
p_loop:                         # below section is also very verbose, manual  |
        la $t0, end_of_sentence # decompose MARS pseudoinstructions into SPIM
        lw $t1, 0($t0)          # instructions
        or $t6, $t1, $s3        # compute end_of_sent == 0 && word_found == 0 |
        bnez $t6, p_loop_end    # check conditions for while loop             |     while( end_of_sentence == 0 && word_found == 0 ) {
        la $t1, input_index
        lw $t2, 0($t1)
        add $t2, $t2, $s0       #
        lb $a0, 0($t2)          # $a0 = inp[input_index]                      |
        li $t3, 0x0a            # 0x0a == \n
        seq $t2, $a0, $t3       #
        sw $t2, 0($t0)          # more terse alternaltive                     |                 end_of_sentence = inp[input_index] == '\n';
                                # move check here to reduce memory accesses   |
        jal is_delimiting_char  #                                             |         is_delim_ch = is_delimiting_char(cur_char);
        li $t0, 1
        bne $v0, $t0, not_delim #                                             |         if ( is_delim_ch == 1 ) {
        sgt $s3, $s2, $zero     # more terse alternaltive                     |                 word_found = char_index > 0;
        j continue
not_delim:                      #                                             |         } else {
        la $t1, input_index
        lw $t2, 0($t1)
        add $t0, $t2, $s0       # $t0 = &inp[input_index]                     |
        add $t1, $s2, $s1       # $t1 = &out[char_index]                      |
        lb $t0, 0($t0)          # $t0 = cur_char                              |
        sb $t0, 0($t1)          # out[char_index] = cur_char;                 |             out[char_index] = cur_char;
        addi $s2, $s2, 1        # char_index++;                               |              char_index++;
continue:                       #                                             |         }
        la $t1, input_index
        lw $t2, 0($t1)
        addi $t2, $t2, 1
        sw $t2, 0($t1)          #                                             |         input_index++;
        j p_loop                #                                             |     }
p_loop_end:
        add $t1, $s2, $s1       # $t1 = &out[char_index]                      |
        sb $zero, 0($t1)        # out[char_index] = '\0';                     |     out[char_index] = '\0';
        move $v0, $s3
        lw $ra, 0x10($sp)       # restore saved registers and $ra
        lw $s0, 0x0c($sp)       # hex for better alignment (again)
        lw $s1, 0x08($sp)
        lw $s2, 0x04($sp)
        lw $s3, 0x00($sp)
        addi $sp, $sp, 0x14     # restore $sp
        jr $ra                  # return $v0                                  |     return word_found;
                                #                                             | }
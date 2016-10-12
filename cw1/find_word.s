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
maxchars:       .word 1001     # #define MAX_CHARS 1001                       |
input_sentence: .space 1001
word:           .space 51
        # input_index & end_of_sentence are stored as registers.              |
        
        .text
main:                          #                                              |int main() {
                               # redundant local temp variable.               |    int word_found = 0;               
                               
m_loop:                        #                                              |    while(1) {
        li $s0, 0              #                                              |        input_index = 0;
        li $s1, 0              #                                              |        end_of_sentence = 0;
        
        la $a0, input_sentence # provide &input_sentence[0] as arg            |
        jal read_input         # call read_input(input_sentence)              |        read_input(input_sentence);
        
        li $v0, 4              # prepare print_string syscall                 |
        la $a0, output_str     # load "output:\n" as argument to syscall      |
        syscall                # call print_string as syscall                 |        print_string("output:\n");
m_inner:                       #                                              |        do {
        la $a0, input_sentence # provide &input_sentence[0] as arg            |
        la $a1, word           # provide &word[0] as 2nd arg                  |
        jal process_input      # call process_input(input_sentence, word)     |            word_found = process_input(input_sentence, word);

        beqz $v0, m_inner_end  #                                              |            if ( word_found == 1 ) {
        la $a0, word           # provide &word[0] as arg to following call    |
        jal output             # call output(word)                            |                output(word);
m_inner_end:                   #                                              |            }
        bne $s1, 1, m_inner    #                                              |        } while ( end_of_sentence != 1 );
        j m_loop
                               #                                              |     return 0;
                               #                                              |}
    
read_input:                    #                                              |void read_input(char* inp) {
        addi $sp, $sp, -4      # preserve $ra                                 |
        sw $ra, ($sp)
        
        move $t0, $a0          # store char* inp temporarily                  |

        li $v0, 4              # prepare print_string syscall                 |
        la $a0, input_str      # load "\ninput: " as argument to syscall      |
        syscall                # call print_string as syscall                 |    print_string("\ninput: ");
        
        li $v0, 8              # prepare Read String syscall                  |
        move $a0, $t0          # load inp into $a0 arg for syscall            |
        la $a1, maxchars       # load MAX_CHARS into $a1 arg..                |
        syscall                # call read_string as syscall                  |    read_string(input_sentence, MAX_CHARS);
        
        lw $ra, ($sp)          # restore $ra                                  |
        addi $sp, $sp, 4
        jr $ra                 # implicit return                              |}
        
output:                        #                                              |void output(char* out) {
        addi $sp, $sp, -4      # preserve $ra                                 |
        sw $ra, ($sp)
        li $v0, 4              # prepare print_string syscall, out = $a0      |
        syscall                # call print_string as syscall                 |    print_string(out);
        
        la $a0, newline        # load "\n" as argument to syscall             |
        syscall                # call print_string as syscall                 |    print_string("\n");

        lw $ra, ($sp)          # restore $ra                                  |
        addi $sp, $sp, 4
        jr $ra                 # implicit return                              |}
        
is_delimiting_char:            #                                              |int is_delimiting_char(char ch) {
        addi $sp, $sp, -4      # preserve $ra                                 |
        sw $ra, ($sp)
        beq $a0, 0x00, ret1    # NUL #                                        |    if(delimiters) {
        beq $a0, 0x0A, ret1    # LF                                           |
        beq $a0, 0x20, ret1    # Space                                        |
        beq $a0, 0x21, ret1    # !                                            |
        beq $a0, 0x28, ret1    # (                                            |         ...
        beq $a0, 0x29, ret1    # )                                            |
        beq $a0, 0x2C, ret1    # ,                                            |
        beq $a0, 0x2D, ret1    # -                                            |
        beq $a0, 0x2E, ret1    # .                                            |         ...
        beq $a0, 0x3F, ret1    # ?                                            |
        beq $a0, 0x5F, ret1    # _                                            |
        li $v0, 0              #                                              |        return 1;
        j ret                  #                                              |    } else {
ret1:       li $v0, 1          #                                              |        return 0;
ret:        lw $ra, ($sp)      # restore $ra                                  |    }
        addi $sp, $sp, 4
        jr $ra                 # return $v0                                   |
                               #                                              |}

process_input:                 #                                              |int process_input(char* input, char* out) {
        addi $sp, $sp, -4      # preserve $ra                                 |
        sw $ra, ($sp)
        move $s2, $a0          # store &inp[0]                                |
        move $s3, $a1          # store &char[0]                               |
        li $s4, 0              #                                              |    int char_index = 0;
                               # local temp variable is redundant             |    int is_delim_ch = 0;              
                               # another temp var, compute on fly.            |    char cur_char = 0; 
        li $s5, 0              #                                              |    int word_found = 0;
        
p_loop:                        #                                              |    while( end_of_sentence == 0 && word_found == 0 ) {
        or $t6, $s1, $s5       # compute end_of_sent == 0 && word_found == 0  |
        bnez $t6, p_loop_end   # check conditions for while loop              |
        
        add $t0, $s0, $s2      
        lb $a0, ($t0)          #                                              |
        seq $s1, $a0, 0x0a     # more terse alternaltive                      |                end_of_sentence = inp[input_index] == '\n';
                               # move check here to reduce memory accesses    |
        jal is_delimiting_char #                                              |        is_delim_ch = is_delimiting_char(cur_char);
        bne $v0, 1, not_delim  #                                              |        if ( is_delim_ch == 1 ) {
        sgt $s5, $s4, $zero    # more terse alternaltive                      |                word_found = char_index > 0;
        j continue
        
not_delim:                     #                                              |        } else {
        add $t0, $s0, $s2      # $t0 = &inp[input_index]                      |
        add $t1, $s4, $s3      # $t1 = &out[char_index]                       |
        lb $t0, ($t0)          # $t0 = cur_char                               |
        sb $t0, ($t1)          # out[char_index] = cur_char;                  |            out[char_index] = cur_char;
        addi $s4, $s4, 1       # char_index++;                                |             char_index++;
                               #                                              |        }
continue:   add $s0, $s0, 1    #                                              |        input_index++;
        j p_loop               #                                              |    }
p_loop_end: 
        add $t1, $s4, $s3      # $t1 = &out[char_index]                       |
        sb $zero, ($t1)        # out[char_index] = '\0';                      |    out[char_index] = '\0';
        move $v0, $s5 
        lw $ra, ($sp)          # restore $ra                                  |
        addi $sp, $sp, 4
        jr $ra                 # return $v0                                   |    return word_found;
                               #                                              |}
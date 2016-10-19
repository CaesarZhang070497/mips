        .text
        .globl main
main:
        
wordcmp:
        sw $ra, -0x04($sp)      # preserve saved registers
        sw $s0, -0x08($sp)      # hex for better alignment
        sw $s1, -0x0c($sp)
        addi $sp, $sp, -0x0c
        move $s0, $a0
        move $s1, $a1
loop:   move $a0, $s0
        jal is_delimiting_char
        
        lb $t0, 0($s0)
        lb $t1, 0($s1)
        sne $t3, $t0, $t1
        or $t3, $t3, $v0
        bnez $t3, skip
        addi $s0, $s0, 1
        addi $s1, $s1, 1
        j loop
skip:   move $a0, $s0
        jal is_delimiting_char
        add $s2, $zero, $v0
        move $a0, $s1
        jal is_delimiting_char
        and $s2, $s2, $v0
        li $v0, 0
        bnez $s2, same
        li $v0, 1
same:   
        lw $s1, 0x08($sp)
        lw $s2, 0x04($sp)
        lw $ra, 0x00($sp)
        addi $sp, $sp, 0x0c     # restore $sp
        jr $ra

wordcpy:
        sw $ra, -0x04($sp)      # preserve saved registers
        sw $s0, -0x08($sp)      # hex for better alignment
        sw $s1, -0x0c($sp)
        sw $s2, -0x10($sp)
        addi $sp, $sp, -0x10
        move $s0, $a0
        move $s1, $a1
        move $s2, $a0
loop2:  
        lb $t0, 0($s0)
        move $a0, $t0
        jal is_delimiting_char
        beqz $v0, end2
        lb $t0, 0($s1)
        sb $t0, 0($s0)
        addi $s0, 1
        addi $s1, 1
        j loop2
end2:   sb $zero, 0($s0)
        move $v0, $s2
        lw $s1, 0x08($sp)
        lw $s2, 0x04($sp)
        lw $ra, 0x00($sp)
        addi $sp, $sp, 0x0c     # restore $sp
        jr $ra
        
process_input:
        sw $ra, -0x04($sp)      # preserve saved registers
        sw $s0, -0x08($sp)      # hex for better alignment
        sw $s1, -0x0c($sp)
        sw $s2, -0x10($sp)
        sw $s3, -0x14($sp)      
        sw $s4, -0x18($sp)      # preserve $ra
        addi $sp, $sp, -0x18
        move $s0, $a0 # cur_char
        li $s1, 0 #parsed
loop3:  lb $t0, 0($s0)
        beqz $t0, end3
        move $a0, $t0
        jal is_delimiting_char
        or $t1, $s1, $v0
        beqz $t1, parse
        seq $s1, $v0, $zero
        addi $s0, $s0, 1
        j loop
parse:  li $s2, 1 #is unique
        li $s3, 0 # int i
search: move $a0, $s0
        move $t0, $s3
        sll $t0, $t0, 2
        la $s4, unique
        add $s4, $s4, $t0
        lw $t0, 0($s4)
        move $a1, $t0
        jal wordcmp
        bnez $v0, cont
        lw $t0, 4($s4)
        addi $t0, $t0, 1
        sw $t0, 4($s4)
        li $s2, 0 #is unque = 0
        j searchd
cont:   addi $s3, $s3, 1
        la $t0, num_unique_words
        lw $t0, ($t0)
        blt $s3, $t0, search
searchd:beqz $s2, not_uniq
        la $s4, unique
        la $t0, num_unique_words
        lw $t0, ($t0)
        sll $t1, $t0, 2
        add $s4, $s4, $t1
        sw $s0, 0($s4)
        li $t1, 1
        sw $t1, 4($s4)
        addi $t1, $t0, 1
        la $t0, num_unique_words
        lw $t1, ($t0)
not_uniq:
        addi $s0, $s0, 1
        li $s1, 1
        j loop
end3: 
count:  li $s3, 0
        move $t0, $s3
        sll $t0, $t0, 2
        la $s4, unique
        add $s4, $s4, $t0
        lw $t0, 4($s4)
        la $t1, max_frequency
        lw $t2, 0($t1)
        blt $t0, $t2, cont2
        beq $t0, $t2, equal
        sw $t0, 0($t1)
        la $a0, word
        lw $a1, 4($s4)
        jal wordcpy
        li $t0, 1
        la $t1, num_words_with_max_frequency
        sw $t0, 0($t1)
        j cont2
equal:  la $t1, num_words_with_max_frequency
        lw $t0, 0($t1)
        addi $t0, $t0, 1
        sw $t0, 0($t1)
cont2:  addi $s3, $s3, 1
        la $t0, num_unique_words
        lw $t0, ($t0)
        blt $s3, $t0, count
        lw $ra, 0x14($sp)       # restore saved registers and $ra
        lw $s0, 0x10($sp)       # hex for better alignment (again)
        lw $s1, 0x0c($sp)
        lw $s2, 0x08($sp)
        lw $s3, 0x04($sp)
        lw $s4, 0x00($sp)
        addi $sp, $sp, 0x18     # restore $sp
        jr $ra
        
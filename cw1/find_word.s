		.data
input_str:	.asciiz "\ninput: "
output_str:	.asciiz "output:\n"
newline: 	.asciiz "\n"
maxchars:	.word 1001					# #define MAX_CHARS 1001
maxwords:	.word 51					# #define MAX_WORD_LENGTH 51

		.text
main:
		li $s0, 0					# s0 = int word_found = 0;
		lw $t0, maxchars
		#mul $t0, $t0, 4
		lw $s1 ($gp)					# s1 = &input_sentence[0]
		add $s2, $s1, $t0 				# s2 = &word[0]
		# li $s3, 0					# s3 = int input_index = 0 | no-op, since resetted in m_loop
		# li $s4, 0					# s4 = int end_of_sentence = 0 | no-op, since resetted in m_loop							
m_loop:
		li $s3, 0					# input_index = 0
		li $s4, 0					# end_of_sentence = 0
		
		move $a0, $s1					# provide &input_sentence[0] as arg to following call
		jal read_input					# call read_input(input_sentence)
		
		li $v0, 4					# prepare print_string syscall
		lw $a0, output_str				# load "output:\n" as argument to syscall
		syscall						# call print_string as syscall
m_inner:
		move $a0, $s1					# provide &input_sentence[0] as arg to following call
		move $a1, $s2					# provide &word[0] as arg to following call
		jal process_input				# call process_input(input_sentence, word)
		move $s0, $v0					# store return value. word_found = process_input(input_sentence, word)
		
		beqz $v0, skip_out				# 
		move $a1, $s2					# provide &word[0] as arg to following call
		jal output					# call output(word)
skip_out:	
		bne $s4, 1, m_inner
		j m_loop

	
read_input:
		move $t0, $a0					# store char* inp temporarily	

		li $v0, 4					# prepare print_string syscall
		la $a0, input_str				# load "\ninput: " as argument to syscall
		syscall						# call print_string as syscall
		
		li $v0, 8					# prepare Read String syscall
		move $a0, $t0					# load inp into $a0 arg for syscall
		la $a1, maxchars				# load MAX_CHARS into $a1 arg..
		syscall						# call read_string as syscall
		
		jr $ra						# implicit return
		
output:
		li $v0, 4					# prepare print_string syscall, out is already in $a0
		syscall						# call print_string as syscall
		
		la $a0, newline					# load "\n" as argument to syscall
		syscall						# call print_string as syscall
		
is_delimiting_char:
		beq $a0, 0x00, ret1
		beq $a0, 0x0A, ret1
		beq $a0, 0x20, ret1
		beq $a0, 0x21, ret1
		beq $a0, 0x28, ret1
		beq $a0, 0x29, ret1
		beq $a0, 0x2C, ret1
		beq $a0, 0x2D, ret1
		beq $a0, 0x2E, ret1
		beq $a0, 0x3F, ret1
		beq $a0, 0x5F, ret1
		li $v0, 0
		jr $ra
ret1:		li $v0, 1
		jr $ra

process_input:
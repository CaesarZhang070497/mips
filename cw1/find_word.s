	.data
	
	.text
main:
	li $v0, 8
	la $a0, ($s0)
	li $a1, 10
	syscall
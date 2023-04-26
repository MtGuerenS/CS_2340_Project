.text
.globl move_sound
move_sound:
	sw $a0, 0($sp)
	sw $a1, -4($sp)
	sw $a2, -8($sp)
	sw $a3, -12($sp)
	li $v0, 31
	li $a0, 56
	li $a1, 1000
	li $a2, 115
	li $a3, 127
	syscall
	lw $a0, 0($sp)
	lw $a1, -4($sp)
	lw $a2, -8($sp)
	lw $a3, -12($sp)
	jr $ra
select_sound:

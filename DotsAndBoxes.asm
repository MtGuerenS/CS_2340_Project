.data
	red: .asciiz "PLAYER 2 \n"

.text
.globl main
.globl switchPlayer
	#a2 = player turn (0 for blue, 1 for red)
	main:
		jal interface
		
		li $a2, 0
		
		loop:	# TEST can delete this line
			bnez $a2, player_2	# if $a2 is 1 then go to player 2
		
			jal input
		
			move $a0, $v0		# 
			move $a1, $v1		# moves the inputs as args for create_line
			
			jal create_line
			jal check_move
			jal save_line
			jal switchPlayer
			
			j loop
			
		player_2:
			li $v0, 4		#
			move $t0, $a0		#
			la $a0, red		# print some stuff
			syscall			#
			move $a0, $t0		#
			
			addi $sp, $sp, -4	# stores args on the stack
			sw $a2, 0($sp)		# player num
		
			lw $a0, display_end
			jal find_01lines

			lw $a2, 0($sp)		# player num
			addi $sp, $sp, 4	# gets args off the stack
			
			jal switchPlayer
			
			j loop			# TEST can delete this line
		
		# example of using create_box
		li $a0, 6
		li $a1, 8
		li $a2, 0
		jal create_box
	
switchPlayer:	addi $a2, $a2, 1
		and $a2, $a2, 1
		jr $ra

exit:
		li $v0, 10 			# terminate the program
		syscall

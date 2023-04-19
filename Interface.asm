.data
.globl display_end
	display_start: .word 0x10040000
	backgrd_end:   .word 0x10042B00	# 4 bits * [(6 pixels * 6 lines + 7 dots) * 64 pixels]
	display_end:   .word 0x10044000

.text
.globl interface
.globl create_line
.globl create_box
# Creates the Interface for Dots and Boxes
# ----------------------------------------
	# Call the subroutine below to set up the bitmap image
	interface:
		lw $s0, display_start	# stores START of display
		lw $s1, backgrd_end	# stores START of background
		lw $s2, display_end	# stores END of display
		
		addi $sp, $sp, -4 	#
		sw $ra, 0($sp)		# preserves original return address
		
		jal background
		
		jal dots
		
		lw $ra, 0($sp)		#
		addi $sp, $sp, 4	# goes back to where it was excuted
		jr $ra			#

# Creates a White Background on the Bitmap
# ----------------------------------------
	background:
		add $t0, $s0, $0	# creates copy of the start of display to increment it
		li $t1, 0xffffff	# $t3 stores the color 'WHITE'
		li $t2, 0xeeeeee	# $t3 stores the color 'GREY'
		fill_space:
			sw $t2, 0($t0)		# makes the pixel grey at $t0
			addi $t0, $t0, 4	# increments display pointer by 4
			bne $t0, $s2, fill_space	# while display start < display end, loop
		jr $ra
	
# Create the Dots for the Interface
# ---------------------------------
	dots:
		add $t0, $s0, 1040	# sets the address of the first dot (4*256+16)
		li $t1, 0x000000	# $t3 stores the color 'BLACK'
		add $t2, $s0, 1279	# t2 is the stopping point for creating dots in col (4*256+255)
		j dots_col
			
		dots_row:
			bge $t0, $s1, return	# exit the loop if col stopping point > background end, return
			addi $t2, $t2, 1791	# updates the col stopping point to the next row
			addi $t0, $t0, 1540	# updates where the row will start
			dots_col:
				sw $t1, 0($t0)		# makes the pixel black at $t0
				addi $t0, $t0, 28	# increments by 8 pixels
				blt $t0, $t2, dots_col	# while display pointer < background end, loop
				j dots_row		# else 
		return:
			jr $ra
		
# Create Line 
# -----------
	# a0 = row num
	# a1 = col num
	# a2 = player num 0/1
	# Notes: a0 and a1 is the player move and a2 determines the color
	create_line:
		bnez $a2, color2
			li $t3, 0x000000	# sets the color to 'BLUE'
			j conditional
		color2:
			li $t3, 0x000000	# sets the color to 'RED'
	
		conditional: 
			and $t1, $a0, 1		# if the row is odd then is is a vert line
			bnez, $t1, vert_line	# if the coord is a vert line, create one
		horz_line:
			addi $t1, $a0, 1	# turns row num given to num from 0-5
			srl $t1, $t1, 1		# this makes it easy to multiply,  t1 = end of line
			
			mul $t2, $t1, 252	# gets the offset from the pixel
			
			mul $t1, $t1, 1540 	# 
			add $t1, $t1, $t2	# y coord of the end of vert line -- calculated vale + offset
			
			add $t2, $a1, 1		# turns col num given to num from 1-5
			srl $t2, $t2, 1		# this makes it easy to multiply,  t1 = end of line
			
			mul $t2, $t2, 28 #32	# x coord
		
			add $t0, $s0, 1016	# stores the loc of the first dot + 1 pixel
			add $t0, $t0, $t1	# adds first dot + y coord, this will move the starting dot up and down
			add $t0, $t0, $t2	# adds x coord to the starting point
			
			add $t1, $t0, 20	# $t0 = counter  $t1 = end point
			lp_horz:
				bgt $t0, $t1, return	# if counter < end, exit
				sw $t3, 0($t0)		# color the pixel at $t0
				addiu $t0, $t0, 4	# increment counter
				j lp_horz
			jr $ra
		vert_line:
			# The few blocks are trying to find the end pixel for the line and store it in $t1
			addi $t1, $a0, 1	# turns row num given to num from 1-5
			srl $t1, $t1, 1		# this makes it easy to multiply,  t1 = end of line
			
			addi $t2, $t1, -1	#
			mul $t2, $t2, 252 	# gets the offset from the pixel
			
			mul $t1, $t1, 1540 	# 
			add $t1, $t1, $t2	# y coord of the end of vert line
			
			add $t2, $a1, 1		# turns col num given to num from 1-5
			srl $t2, $t2, 1		# this makes it easy to multiply,  t1 = end of line
			
			mul $t2, $t2, 28 	#
			add $t0, $s0, 1036 	# x coord of the end of vert line
			
			add $t1, $t1, $t2	#
			add $t1, $t0, $t1	# combines the x and y coods to make end point
			
			addi $t0, $t1, -1536	# sets the start pixel for loop 8 pixels down (8*4*64)
			lp_vert:
				addi $t0, $t0, 256	# go down one pixel
				bgt $t0, $t1, return	# if start > end, stop
				sw $t3, 0($t0)		# color the pixel at $t0
				j lp_vert
			jr $ra
			
# Create Box 
# -----------
	# a0 = row num (0-4)
	# a1 = col num	(0-6)
	# a2 = player num 0/1
	# Notes: a0 and a1 is the player move and a2 determines the color
	create_box:
		bnez $a2, color_2
			li $t3, 0x92b4f7	# sets the color to 'BLUE'
			j box_setup
		color_2:
			li $t3, 0xe63e3e	# sets the color to 'RED'
		box_setup:
			addi $a0, $a0, 1	# turns row num given to num from 0-5
			srl $a0, $a0, 1		# this makes it easy to multiply,  t1 = end of line
			
			add $a1, $a1, 1		# turns col num given to num from 1-5
			srl $a1, $a1, 1		# this makes it easy to multiply,  t1 = end of line
		
			addi $t1, $a0, 0	# places row num 0-4 into $t1
			
			mul $t2, $t1, 252	# gets the offset from the pixel
			
			mul $t1, $t1, 1540	# 
			add $t1, $t1, $t2	# y coord of the end of vert line -- calculated vale + offset
			
			add $t2, $a1, 1		# places col num 0-5 into $t2
			
			mul $t2, $t2, 28 	# x coord
		
			add $t0, $s0, 1272 	# stores the loc of the first pixel in box 0,0
			add $t0, $t0, $t1	# adds first dot + y coord, this will move the starting dot up and down
			add $t0, $t0, $t2	# adds x coord to the starting point
			
			add $t1, $t0, 20 	# $t0 = counter  $t1 = end point -- for lines
			add $t2, $t1, 1280 	# $t3 = end of box (256 * 5)
			
			bnez $a2, computer	#if its computer turn, increment computer score
			addi $s3, $s3, 1	#if its player turn, increment player score
			j lp_box		#jump past increment computer score
			
	computer:	addi $s4, $s4, 1	#increment computer score
			
			lp_box:
				bgt $t0, $t1, new_line	# if counter < end, exit
				sw $t3, 0($t0)		# color the pixel at $t0
				addiu $t0, $t0, 4	# increment counter
				j lp_box
			new_line:
				addiu $t0, $t0, 232 	# sets the counter to begnning of next line (256 - 4 * 5)
				addiu $t1, $t1, 256	# sets the end to the next line
				bge $t2, $t1, lp_box
				jr $ra
		
	exit:
		li $v0, 10 	# terminate the program
		syscall

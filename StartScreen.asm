.data
	display_s: 	.word 0x10040000
	backgrd_e:   	.word 0x10042B00	# 4 bits * [(6 pixels * 6 lines + 7 dots) * 64 pixels]
	display_e:   	.word 0x10044000
	sure:		.asciiz "Enter 5 to confirm choice\n"

.text
.globl startScreen
.globl endScreen
.globl blue_wins
.globl red_wins
.globl tied
# Creates the Interface for Dots and Boxes
# ----------------------------------------
	# Call the subroutine below to set up the bitmap image
	startScreen:
		lw $s0, display_s	# stores START of display
		lw $s1, backgrd_e	# stores START of background
		lw $s2, display_e	# stores END of display
		
		addi $sp, $sp, -4 	#
		sw $ra, 0($sp)		# preserves original return address
		
	start:	jal background
		
		add $t0, $s0, 1300
		
		jal title
		
		li $t8, 3584
		
		bne $a1, 2, choice1
		li $t1, 0		# BLACK
		li $t9, 0xffffff	# WHITE
	choice1:	
		li $a0, 2
		add $t0, $s0, 3604
		jal choice
		li $t9, 0		# BLACK
		li $t1, 0xffffff	# WHITE
	
		bne $a1, 1, choice2
		li $t1, 0		# BLACK
		li $t9, 0xffffff	# WHITE
	choice2:
		li $a0, 1
		add $t0, $t0, $t8
		jal choice
		li $t9, 0		# BLACK
		li $t1, 0xffffff	# WHITE
	
		bne $a1, 0, choice3
		li $t1, 0		# BLACK
		li $t9, 0xffffff	# WHITE
	choice3:
		li $a0, 0	
		add $t0, $t0, $t8
		jal choice
		li $t9, 0		# BLACK
		li $t1, 0xffffff	# WHITE
		
		beq $a1, 3, input
		li $v0, 4
		la $a0, sure
		syscall
		
		move $s7, $a1
		
	input:	li $v0, 5
		syscall
		move $a1, $v0
		
		bne $a1, 5, start
		
		lw $ra, 0($sp)		#
		addi $sp, $sp, 4	# goes back to where it was excuted
		jr $ra			#

# Creates a White Background on the Bitmap
# ----------------------------------------
	background:
		add $t0, $s0, $0	# creates copy of the start of display to increment it
		li $t9, 0		# $t3 stores the color 'BLACK'
		li $t1, 0xffffff	# $t3 stores the color 'WHITE'
		fill_space:
			sw $t9, 0($t0)		# makes the pixel grey at $t0
			addi $t0, $t0, 4	# increments display pointer by 4
			bne $t0, $s2, fill_space	# while display start < display end, loop
		jr $ra
		
#	endScreen:
#		li $t9, 0
#		li $t8, 0
#	repeat:	li $a1, 4096
#		li $v0, 42
#		syscall
#		move $t1, $a0
#		sll $t1, $t1, 2
#		add $t0, $s0, $t1
#	next:	lw $t2, 0($t0)
#		bne $t0, $s2, loop
#		addi $t0, $s0, -4
#	loop:	addi $t0, $t0, 4
#		beqz $t2, next
#		li $v0, 32
#		li $a0, 3
#		syscall
#		sw $t9, -4($t0)
#		addi $t8, $t8, 1
#		bne $t8, 4000, repeat
#		j return
		
	endScreen:
		li $t9, 0
		li $t8, 0
	repeat:	li $a1, 4096
		li $v0, 42
		syscall
		move $t1, $a0
		sll $t1, $t1, 2
		add $t0, $s0, $t1
		lw $t2, 0($t0)
		beqz $t2, repeat
		li $v0, 32
		li $a0, 1
		syscall
		sw $t9, ($t0)
		addi $t8, $t8, 1
		bne $t8, 3373, repeat
		j return
		
	red_wins:
		li $t9, 0xffffff
		addi $t0, $s0, 1860
		
		sw $t9, 0($t0)
		sw $t9, 4($t0)
		sw $t9, 8($t0)
		sw $t9, 256($t0)
		sw $t9, 264($t0)
		sw $t9, 512($t0)
		sw $t9, 516($t0)
		sw $t9, 768($t0)
		sw $t9, 776($t0)
		sw $t9, 1024($t0)
		sw $t9, 1032($t0)
		
		sw $t9, 16($t0)
		sw $t9, 20($t0)
		sw $t9, 24($t0)
		sw $t9, 272($t0)
		sw $t9, 528($t0)
		sw $t9, 532($t0)
		sw $t9, 536($t0)
		sw $t9, 784($t0)
		sw $t9, 1040($t0)
		sw $t9, 1044($t0)
		sw $t9, 1048($t0)
		
		sw $t9, 32($t0)
		sw $t9, 36($t0)
		sw $t9, 288($t0)
		sw $t9, 296($t0)
		sw $t9, 544($t0)
		sw $t9, 552($t0)
		sw $t9, 800($t0)
		sw $t9, 808($t0)
		sw $t9, 1056($t0)
		sw $t9, 1060($t0)
		
		sw $t9, 56($t0)
		sw $t9, 72($t0)
		sw $t9, 312($t0)
		sw $t9, 328($t0)
		sw $t9, 568($t0)
		sw $t9, 576($t0)
		sw $t9, 584($t0)
		sw $t9, 824($t0)
		sw $t9, 832($t0)
		sw $t9, 840($t0)
		sw $t9, 1084($t0)
		sw $t9, 1092($t0)
		
		sw $t9, 80($t0)
		sw $t9, 336($t0)
		sw $t9, 592($t0)
		sw $t9, 848($t0)
		sw $t9, 1104($t0)
		
		sw $t9, 88($t0)
		sw $t9, 100($t0)
		sw $t9, 344($t0)
		sw $t9, 348($t0)
		sw $t9, 356($t0)
		sw $t9, 600($t0)
		sw $t9, 604($t0)
		sw $t9, 608($t0)
		sw $t9, 612($t0)
		sw $t9, 856($t0)
		sw $t9, 864($t0)
		sw $t9, 868($t0)
		sw $t9, 1112($t0)
		sw $t9, 1124($t0)
		
		sw $t9, 108($t0)
		sw $t9, 112($t0)
		sw $t9, 116($t0)
		sw $t9, 364($t0)
		sw $t9, 620($t0)
		sw $t9, 624($t0)
		sw $t9, 628($t0)
		sw $t9, 884($t0)
		sw $t9, 1132($t0)
		sw $t9, 1136($t0)
		sw $t9, 1140($t0)
		j return
		
	blue_wins:
		li $t9, 0xffffff
		addi $t0, $s0, 1872
		
		sw $t9, -16($t0)
		sw $t9, -20($t0)
		sw $t9, 236($t0)
		sw $t9, 244($t0)
		sw $t9, 492($t0)
		sw $t9, 496($t0)
		sw $t9, 748($t0)
		sw $t9, 756($t0)
		sw $t9, 1004($t0)
		sw $t9, 1008($t0)
		
		sw $t9, -4($t0)
		sw $t9, 252($t0)
		sw $t9, 508($t0)
		sw $t9, 764($t0)
		sw $t9, 1020($t0)
		sw $t9, 1024($t0)
		sw $t9, 1028($t0)
		
		sw $t9, 12($t0)
		sw $t9, 20($t0)
		sw $t9, 268($t0)
		sw $t9, 276($t0)
		sw $t9, 524($t0)
		sw $t9, 532($t0)
		sw $t9, 780($t0)
		sw $t9, 788($t0)
		sw $t9, 1036($t0)
		sw $t9, 1040($t0)
		sw $t9, 1044($t0)
		
		sw $t9, 28($t0)
		sw $t9, 32($t0)
		sw $t9, 36($t0)
		sw $t9, 284($t0)
		sw $t9, 540($t0)
		sw $t9, 544($t0)
		sw $t9, 548($t0)
		sw $t9, 796($t0)
		sw $t9, 1052($t0)
		sw $t9, 1056($t0)
		sw $t9, 1060($t0)
		
		sw $t9, 56($t0)
		sw $t9, 72($t0)
		sw $t9, 312($t0)
		sw $t9, 328($t0)
		sw $t9, 568($t0)
		sw $t9, 576($t0)
		sw $t9, 584($t0)
		sw $t9, 824($t0)
		sw $t9, 832($t0)
		sw $t9, 840($t0)
		sw $t9, 1084($t0)
		sw $t9, 1092($t0)
		
		sw $t9, 80($t0)
		sw $t9, 336($t0)
		sw $t9, 592($t0)
		sw $t9, 848($t0)
		sw $t9, 1104($t0)
		
		sw $t9, 88($t0)
		sw $t9, 100($t0)
		sw $t9, 344($t0)
		sw $t9, 348($t0)
		sw $t9, 356($t0)
		sw $t9, 600($t0)
		sw $t9, 604($t0)
		sw $t9, 608($t0)
		sw $t9, 612($t0)
		sw $t9, 856($t0)
		sw $t9, 864($t0)
		sw $t9, 868($t0)
		sw $t9, 1112($t0)
		sw $t9, 1124($t0)
		
		sw $t9, 108($t0)
		sw $t9, 112($t0)
		sw $t9, 116($t0)
		sw $t9, 364($t0)
		sw $t9, 620($t0)
		sw $t9, 624($t0)
		sw $t9, 628($t0)
		sw $t9, 884($t0)
		sw $t9, 1132($t0)
		sw $t9, 1136($t0)
		sw $t9, 1140($t0)
		j return
		
	tied:
		li $t9, 0xffffff
		addi $t0, $s0, 1896
		
		sw $t9, 0($t0)
		sw $t9, 4($t0)
		sw $t9, 8($t0)
		sw $t9, 260($t0)
		sw $t9, 516($t0)
		sw $t9, 772($t0)
		sw $t9, 1028($t0)
		
		sw $t9, 16($t0)
		sw $t9, 20($t0)
		sw $t9, 24($t0)
		sw $t9, 276($t0)
		sw $t9, 532($t0)
		sw $t9, 788($t0)
		sw $t9, 1040($t0)
		sw $t9, 1044($t0)
		sw $t9, 1048($t0)
		
		sw $t9, 32($t0)
		sw $t9, 36($t0)
		sw $t9, 40($t0)
		sw $t9, 288($t0)
		sw $t9, 544($t0)
		sw $t9, 548($t0)
		sw $t9, 552($t0)
		sw $t9, 800($t0)
		sw $t9, 1056($t0)
		sw $t9, 1060($t0)
		sw $t9, 1064($t0)
		j return
		
	choice:
		addi $t3, $t0, 836
		add $t2, $t0, 216
		horizontal:
			sw $t1, 0($t0)
			addi $t0, $t0, 4
			bne $t0, $t2, horizontal
		addi $t0, $t0, 32
		sw $t1, 4($t0)
		add $t2, $t0, 216
		horizontal2:
			sw $t9, 8($t0)
			addi $t0, $t0, 4
			bne $t0, $t2, horizontal2
		sw $t1, 8($t0)
		addi $t0, $t0, 40
		addi $t4, $t0, 1792
	vertical:
		sw $t1, 0($t0)
		addi $t5, $t0, 228
		inner_fill:
			sw $t9, 4($t0)
			addi $t0, $t0, 4
			bne $t0, $t5, inner_fill
		sw $t1, 0($t0)
		addi $t0, $t0, 28
		bne $t0, $t4, vertical
		
		sw $t1, 4($t0)
		add $t2, $t0, 216
		horizontal3:
			sw $t9, 8($t0)
			addi $t0, $t0, 4
			bne $t0, $t2, horizontal3
		sw $t1, 8($t0)
		
		addi $t0, $t0, 48
		add $t2, $t0, 216
		horizontal4:
			sw $t1, 0($t0)
			addi $t0, $t0, 4
			bne $t0, $t2, horizontal4
		
		sw $t1, 0($t3)
		sw $t1, 4($t3)
		sw $t1, 8($t3)
		sw $t1, 256($t3)
		sw $t1, 264($t3)
		sw $t1, 512($t3)
		sw $t1, 516($t3)
		sw $t1, 520($t3)
		sw $t1, 768($t3)
		sw $t1, 1024($t3)
		
		sw $t1, 16($t3)
		sw $t1, 272($t3)
		sw $t1, 528($t3)
		sw $t1, 784($t3)
		sw $t1, 1040($t3)
		sw $t1, 1044($t3)
		sw $t1, 1048($t3)
		
		sw $t1, 32($t3)
		sw $t1, 36($t3)
		sw $t1, 40($t3)
		sw $t1, 288($t3)
		sw $t1, 296($t3)
		sw $t1, 544($t3)
		sw $t1, 548($t3)
		sw $t1, 552($t3)
		sw $t1, 800($t3)
		sw $t1, 808($t3)
		sw $t1, 1056($t3)
		sw $t1, 1064($t3)
		
		sw $t1, 48($t3)
		sw $t1, 56($t3)
		sw $t1, 304($t3)
		sw $t1, 312($t3)
		sw $t1, 564($t3)
		sw $t1, 820($t3)
		sw $t1, 1076($t3)
		
		sw $t1, 64($t3)
		sw $t1, 68($t3)
		sw $t1, 72($t3)
		sw $t1, 320($t3)
		sw $t1, 576($t3)
		sw $t1, 580($t3)
		sw $t1, 584($t3)
		sw $t1, 832($t3)
		sw $t1, 1088($t3)
		sw $t1, 1092($t3)
		sw $t1, 1096($t3)
		
		sw $t1, 80($t3)
		sw $t1, 84($t3)
		sw $t1, 88($t3)
		sw $t1, 336($t3)
		sw $t1, 344($t3)
		sw $t1, 592($t3)
		sw $t1, 596($t3)
		sw $t1, 848($t3)
		sw $t1, 856($t3)
		sw $t1, 1104($t3)
		sw $t1, 1112($t3)
		
		addi $t0, $t0, -2776
		
		bne $a0, 2, one
		sw $t1, -24($t3)
		sw $t1, -20($t3)
		sw $t1, -16($t3)
		sw $t1, 240($t3)
		sw $t1, 488($t3)
		sw $t1, 492($t3)
		sw $t1, 496($t3)
		sw $t1, 744($t3)
		sw $t1, 1000($t3)
		sw $t1, 1004($t3)
		sw $t1, 1008($t3)
		
		sw $t1, 96($t3)
		sw $t1, 100($t3)
		sw $t1, 104($t3)
		sw $t1, 352($t3)
		sw $t1, 608($t3)
		sw $t1, 612($t3)
		sw $t1, 616($t3)
		sw $t1, 872($t3)
		sw $t1, 1120($t3)
		sw $t1, 1124($t3)
		sw $t1, 1128($t3)
		j return
		
	one:	bne $a0, 1, zeroS
		sw $t1, -20($t3)
		sw $t1, 236($t3)
		sw $t1, 232($t3)
		sw $t1, 492($t3)
		sw $t1, 748($t3)
		sw $t1, 1000($t3)
		sw $t1, 1004($t3)
		sw $t1, 1008($t3)
		j return
		
	zeroS:	sw $t1, -24($t3)
		sw $t1, -20($t3)
		sw $t1, -16($t3)
		sw $t1, 232($t3)
		sw $t1, 240($t3)
		sw $t1, 488($t3)
		sw $t1, 496($t3)
		sw $t1, 744($t3)
		sw $t1, 752($t3)
		sw $t1, 1000($t3)
		sw $t1, 1004($t3)
		sw $t1, 1008($t3)
	
		sw $t1, 96($t3)
		sw $t1, 100($t3)
		sw $t1, 104($t3)
		sw $t1, 352($t3)
		sw $t1, 608($t3)
		sw $t1, 612($t3)
		sw $t1, 616($t3)
		sw $t1, 872($t3)
		sw $t1, 1120($t3)
		sw $t1, 1124($t3)
		sw $t1, 1128($t3)
		
	return:	jr $ra
		
	title:
		sw $t1, 0($t0)
		sw $t1, 4($t0)
		sw $t1, 256($t0)
		sw $t1, 264($t0)
		sw $t1, 512($t0)
		sw $t1, 520($t0)
		sw $t1, 768($t0)
		sw $t1, 776($t0)
		sw $t1, 1024($t0)
		sw $t1, 1028($t0)
		
		sw $t1, 20($t0)
		sw $t1, 24($t0)
		sw $t1, 272($t0)
		sw $t1, 284($t0)
		sw $t1, 528($t0)
		sw $t1, 540($t0)
		sw $t1, 784($t0)
		sw $t1, 796($t0)
		sw $t1, 1044($t0)
		sw $t1, 1048($t0)
		
		sw $t1, 36($t0)
		sw $t1, 40($t0)
		sw $t1, 44($t0)
		sw $t1, 296($t0)
		sw $t1, 552($t0)
		sw $t1, 808($t0)
		sw $t1, 1064($t0)
		
		sw $t1, 56($t0)
		sw $t1, 60($t0)
		sw $t1, 308($t0)
		sw $t1, 568($t0)
		sw $t1, 828($t0)
		sw $t1, 1076($t0)
		sw $t1, 1080($t0)
		
		sw $t1, 80($t0)
		sw $t1, 332($t0)
		sw $t1, 340($t0)
		sw $t1, 588($t0)
		sw $t1, 592($t0)
		sw $t1, 596($t0)
		sw $t1, 844($t0)
		sw $t1, 852($t0)
		sw $t1, 1100($t0)
		sw $t1, 1108($t0)
		
		sw $t1, 92($t0)
		sw $t1, 104($t0)
		sw $t1, 348($t0)
		sw $t1, 352($t0)
		sw $t1, 360($t0)
		sw $t1, 604($t0)
		sw $t1, 608($t0)
		sw $t1, 612($t0)
		sw $t1, 616($t0)
		sw $t1, 860($t0)
		sw $t1, 868($t0)
		sw $t1, 872($t0)
		sw $t1, 1116($t0)
		sw $t1, 1128($t0)
		
		sw $t1, 112($t0)
		sw $t1, 116($t0)
		sw $t1, 368($t0)
		sw $t1, 376($t0)
		sw $t1, 624($t0)
		sw $t1, 632($t0)
		sw $t1, 880($t0)
		sw $t1, 888($t0)
		sw $t1, 1136($t0)
		sw $t1, 1140($t0)
		
		sw $t1, 136($t0)
		sw $t1, 140($t0)
		sw $t1, 392($t0)
		sw $t1, 400($t0)
		sw $t1, 648($t0)
		sw $t1, 652($t0)
		sw $t1, 904($t0)
		sw $t1, 912($t0)
		sw $t1, 1160($t0)
		sw $t1, 1164($t0)
		
		sw $t1, 156($t0)
		sw $t1, 160($t0)
		sw $t1, 408($t0)
		sw $t1, 420($t0)
		sw $t1, 664($t0)
		sw $t1, 676($t0)
		sw $t1, 920($t0)
		sw $t1, 932($t0)
		sw $t1, 1180($t0)
		sw $t1, 1184($t0)
		
		sw $t1, 172($t0)
		sw $t1, 180($t0)
		sw $t1, 428($t0)
		sw $t1, 436($t0)
		sw $t1, 688($t0)
		sw $t1, 940($t0)
		sw $t1, 948($t0)
		sw $t1, 1196($t0)
		sw $t1, 1204($t0)
		
		sw $t1, 188($t0)
		sw $t1, 192($t0)
		sw $t1, 196($t0)
		sw $t1, 444($t0)
		sw $t1, 700($t0)
		sw $t1, 704($t0)
		sw $t1, 708($t0)
		sw $t1, 956($t0)
		sw $t1, 1212($t0)
		sw $t1, 1216($t0)
		sw $t1, 1220($t0)
		
		sw $t1, 208($t0)
		sw $t1, 212($t0)
		sw $t1, 460($t0)
		sw $t1, 720($t0)
		sw $t1, 980($t0)
		sw $t1, 1228($t0)
		sw $t1, 1232($t0)

		jr $ra

# Demo for painting
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
.data
displayAddress: .word 0x10008000
frog_x:		.word 16			# set frog position
frog_y:		.word 28 			# to (16,28) (placing FL leg)

.text
lw $t0, displayAddress # $t0 stores the base address for display
li $t1, 0xff0000 # $t1 stores the red colour code
li $t2, 0x4dad53 # $t2 stores the green colour used for the land
li $t3, 0x967bb8 # $t3 stores the lavender colour used for the frog
sw $t1, 0($t0) # paint the first (top-left) unit red.
sw $t2, 4($t0) # paint the second unit on the first row green. Why $t0+4?
sw $t3, 128($t0) # paint the first unit on the second row blue. Why +128?


#
# Set/draw the background 
#
lw $t0, displayAddress 		# $t0 stores the base address for display (reset back to zero)


# draw the destination green land

# initialize the Loop variables $t4 and $t5 
add $t4, $t4, $zero		# set $t4 to zero 
addi $t5, $t5, 256		# set $t5 to 256 

draw_destination:
beq $t4, $t5, end_draw_destination	# Branch to Exit if $t4 == 512
sw $t2, 0($t0)				# paint the first unit on the first row green. 
addi $t0, $t0, 4			# move to the next pixel in the bitmap

addi $t4, $t4, 1		# incrment $t4 by 1
j draw_destination

end_draw_destination:

# draw the river


# draw the middle green land
addi $t4, $t4, 256		# set $t4 to 512. Since $t4 was last 256, 512 = 256 + 256 
addi $t5, $t5, 384		# set $t5 to 640. ($t5 was last 256, and 640 = 258 + 384)
addi $t0, $t0, 1024		# set $t0 to the new beginning pixel

draw_middle:
beq $t4, $t5, end_draw_middle	# Branch to Exit if $t4 == 640
sw $t2, 0($t0)			# paint the first unit on the first row green. 
addi $t0, $t0, 4		# move to the next pixel in the bitmap

addi $t4, $t4, 1		# incrment $t4 by 1
j draw_middle

end_draw_middle:

# draw the road


# draw the starting green land 
addi $t4, $t4, 256		# set $t4 to 896. Since $t4 was last 640, 896 = 640 + 256 
addi $t5, $t5, 384		# set $t5 to 1024. ($t5 was last 640, and 1024 = 640 + 384)
addi $t0, $t0, 1024		# set $t0 to the new beginning pixel

draw_beginning:
beq $t4, $t5, end_draw_beginning	# Branch to Exit if $t4 == 640
sw $t2, 0($t0)				# paint the first unit on the first row green. 
addi $t0, $t0, 4			# move to the next pixel in the bitmap

addi $t4, $t4, 1			# incrment $t4 by 1
j draw_beginning

end_draw_beginning:


#
# Draw the frog
#

frog_movement:
lw $t0, displayAddress 		# $t0 stores the base address for display
la $t6, frog_x 			# $t6 has the same address as frog_x
lw $t7, 0($t6)			# Fetch x position of frog
la $t6, frog_y 			# $t6 has the same address as frog_x
lw $t8, 0($t6)			# Fetch y position of frog
sll $t7, $t7, 2			# Multiply $t7 by 4
sll $t8, $t8, 7			# Multiply $t8 by 128
add $t0, $t0, $t8		# Add y offset to $t0
add $t0, $t0, $t7		# Add x offset to $t0

jal draw_frog

# Function: drawing the frog!
draw_frog:
sw $t3, 0($t0) 		# draw the front left leg at the specified frog_x and frog_y coordinates. 
sw $t3, 12($t0) 	# draw the front right leg
addi $t0, $t0, 132 	# Second Row of frog (upper half of body)
sw $t3, 0($t0) 		# 
sw $t3, 4($t0) 		#
addi $t0, $t0, 128 	# Third Row of frog (lower half of body) 
sw $t3, 0($t0) 		# 
sw $t3, 4($t0) 		# 
addi $t0, $t0, 124 	# Lower legs of frog 
sw $t3, 0($t0) 		# 
sw $t3, 12($t0) 	# 
jr $ra

li $v0, 10 # terminate the program gracefully
syscall

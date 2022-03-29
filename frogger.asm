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

.text
lw $t0, displayAddress # $t0 stores the base address for display
li $t1, 0xff0000 # $t1 stores the red colour code
li $t2, 0x4dad53 # $t2 stores the green colour code
li $t3, 0x0000ff # $t3 stores the blue colour code
sw $t1, 0($t0) # paint the first (top-left) unit red.
sw $t2, 4($t0) # paint the second unit on the first row green. Why $t0+4?
sw $t3, 128($t0) # paint the first unit on the second row blue. Why +128?

# Set/draw the background 


# draw the destination green land

# initialize the Loop variables $t4 and $t5 
add $t4, $t4, $zero		# set $t4 to zero 
addi $t5, $t5, 256		# set $t5 to 256 

draw_destination:
beq $t4, $t5, start_middle_draw	# Branch to Exit if $t4 == 512
sw $t2, 0($t0)			# paint the first unit on the first row green. 
addi $t0, $t0, 4		# move to the next pixel in the bitmap

addi $t4, $t4, 1		# incrment $t4 by 1
j draw_destination

# draw the river


# draw the middle green land
start_middle_draw:
addi $t4, $t4, 256		# set $t4 to 512. Since $t4 was last 256, 512 = 256 + 256 
addi $t5, $t5, 384		# set $t5 to 640. ($t5 was last 256, and 640 = 258 + 384)
addi $t0, $t0, 1024		# set $t0 to the new beginning pixel

draw_middle:
beq $t4, $t5, start_beginning_draw	# Branch to Exit if $t4 == 640
sw $t2, 0($t0)				# paint the first unit on the first row green. 
addi $t0, $t0, 4			# move to the next pixel in the bitmap

addi $t4, $t4, 1		# incrment $t4 by 1
j draw_middle


# draw the road


# draw the starting green land 
start_beginning_draw:
addi $t4, $t4, 256		# set $t4 to 896. Since $t4 was last 640, 896 = 640 + 256 
addi $t5, $t5, 384		# set $t5 to 1024. ($t5 was last 640, and 1024 = 640 + 384)
addi $t0, $t0, 1024		# set $t0 to the new beginning pixel

draw_beginning:
beq $t4, $t5, Exit		# Branch to Exit if $t4 == 640
sw $t2, 0($t0)			# paint the first unit on the first row green. 
addi $t0, $t0, 4		# move to the next pixel in the bitmap

addi $t4, $t4, 1		# incrment $t4 by 1
j draw_beginning

Exit:
li $v0, 10 # terminate the program gracefully
syscall

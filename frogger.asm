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
li $t2, 0x00ff00 # $t2 stores the green colour code
li $t3, 0x0000ff # $t3 stores the blue colour code
sw $t1, 0($t0) # paint the first (top-left) unit red.
sw $t2, 4($t0) # paint the second unit on the first row green. Why $t0+4?
sw $t3, 128($t0) # paint the first unit on the second row blue. Why +128?

# Set/draw the background 

# draw the destination green land

# initialize the Loop variables $t1 and $t2 
add $t4, $t4, $zero	# set $t4 to zero 
addi $t5, $t5, 256	# set $t5 to 256 

draw_destination:
beq $t4, $t5, Exit	# Branch to Exit if $t4 == 512
sw $t2, 0($t0)		# paint the first unit on the first row green. 
addi $t0, $t0, 4	# move to the next pixel in the bitmap

addi $t4, $t4, 1	# incrment $t4 by 1
j draw_destination

# draw the river


# draw the middle green land


# draw the road


# draw the starting green land 

Exit:
li $v0, 10 # terminate the program gracefully
syscall

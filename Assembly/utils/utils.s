.text
.globl atoi
.globl itoa
.globl clear_buffer

.type atoi, @function
.type itoa, @function
.type clear_buffer, @function

# NOTE: In MIPS architecture, to make the CPU pipeline more efficient, 
# there is a feature called Branch Delay Slot.
# When the CPU encounters a branch (like beq, bgt, j) it doesn't immediately jump.
# Instead it always executes the one instruction immediately following the branch 
# before taking the jump. Because of this, there is a strict rule in MIPS that you  
# can't put a branch or a jump instruction inside the delay slot of another branch
# Doing so is undefined behaviour and processors might through Illegal Instruction
# exception and crash
# NOTE: This is why we have nops after branch instructions

### atoi start
## args:
##      * a0: input buffer
##      * a1: maximum size of the buffer
## This function reads a buffer and converts it into an integer
## Incase if there is a invalid digit, retruns the number parsed 
## upto that point
## Returns: $v0 = value of the integer read
atoi:
  move  $t0, $a0                # $t0 = current buffer pointer
  move  $t1, $a1                # $t1 = remaining length of the buffer
  li    $v0, 0                  # $v0 = accumulator
  li    $t5, 0                  # $t5 = sign of the number

# Early exit of the function incase of empty buffer
  beqz  $t1, atoi_end 

# Check the first byte for '+' or '-'
  lb    $t3, 0($t0)              
  beq   $t3, 43, pos_start
  nop
  beq   $t3, 45, neg_start
  nop
  blt   $t3, 48, invalid
  nop
  bgt   $t3, 57, invalid
  nop
  j     atoi_loop

neg_start:
  li    $t5, 1
  addi  $t0, $t0, 1
  addi  $t1, $t1, -1
  j     atoi_loop

pos_start:
  addi  $t0, $t0, 1
  addi  $t1, $t1, -1
  j     atoi_loop

atoi_loop:
# if remaining bytes is 0, the next byte is '\n' or null terminator
# the buffer has ended
  beqz  $t1, atoi_loop_end
  nop
  lb    $t3, 0($t0)
  beqz  $t3, atoi_loop_end
  nop
  beq   $t3, 10, atoi_loop_end

# invalid character in the middle, just return the value parsed upto that point
  blt   $t3, 48, invalid_mid
  nop
  bgt   $t3, 57, invalid_mid

  andi  $t4, $t3, 0x0F
  
# add the value to the accumulator
  li    $t6, 10
  mult  $v0, $t6   
  mflo  $v0
  add   $v0, $v0, $t4

# increment the pointer and decrement the remaining bytes
  addi  $t0, $t0, 1
  addi  $t1, $t1, -1
  j     atoi_loop

atoi_loop_end:
# if sign is positive then end otherwise negate the accumulator
  beqz  $t5, atoi_end
  nop
  neg   $v0, $v0
  j     atoi_end

invalid:
  li    $v0, 0
  j     atoi_end

invalid_mid:
  j     atoi_loop_end

atoi_end: 
  jr    $ra
### atoi end

### itoa start
## args:
##      * a0: input buffer
##      * a1: maximum size of the buffer
##      * a2: input number
## This function converts an integer into a string buffer
## Returns: $v0 = length of the written string (excluding null terminator)
itoa:
  move  $t0, $a0                # $t0 = current buffer pointer
  move  $t1, $a1                # $t1 = remaining buffer capacity
  move  $t2, $a2                # $t2 = number to convert
  li    $t3, 0                  # $t3 = negative flag
  li    $v0, 0                  # $v0 = string length counter

# Early exit if buffer size is 0
  beqz  $t1, itoa_end
  
# Reserve 1 byte for the null terminator
  addi  $t1, $t1, -1
# If size was 1, just write '\0' and return
  beqz  $t1, itoa_terminate     

# Handle 0 explicitly to avoid bypassing the division loop
  bnez  $t2, itoa_check_sign
  li    $t4, 48                 
  sb    $t4, 0($t0)
  addi  $t0, $t0, 1
  li    $v0, 1
  j     itoa_terminate

itoa_check_sign:
  bgtz  $t2, itoa_loop_setup
# Set negative flag
  li    $t3, 1                  
# Make number positive
  neg   $t2, $t2                
# Reserve 1 byte for the '-' sign
  addi  $t1, $t1, -1            

itoa_loop_setup:
# Divisor
  li    $t5, 10                 

itoa_loop:
# Stop if out of space
  beqz  $t1, itoa_finish_digits 
  nop
# Stop if no more digits to extract
  beqz  $t2, itoa_finish_digits 

  div   $t2, $t5
  mflo  $t2                     
  mfhi  $t6                     

# Convert remainder to ASCII digit
  addi  $t6, $t6, 48            
# Store character, advance buffer pointer, decrement capacity
  sb    $t6, 0($t0)             
  addi  $t0, $t0, 1             
  addi  $t1, $t1, -1            
# Increment string length
  addi  $v0, $v0, 1             
  j     itoa_loop

itoa_finish_digits:
  beqz  $t3, itoa_reverse
# Append negative sign if the original number was negative
  li    $t6, 45                 
  sb    $t6, 0($t0)
  addi  $t0, $t0, 1
  addi  $v0, $v0, 1

itoa_reverse:
# The string is currently backwards (LSB to MSB). Reverse it in-place.
  move  $t7, $a0                
  move  $t8, $t0
  addi  $t8, $t8, -1            

itoa_reverse_loop:
  bge   $t7, $t8, itoa_terminate
  lb    $t6, 0($t7)
  lb    $t9, 0($t8)
# Swap characters
  sb    $t9, 0($t7)             
  sb    $t6, 0($t8)
# Move start pointer forward
  addi  $t7, $t7, 1             
# Move end pointer backward
  addi  $t8, $t8, -1            
  j     itoa_reverse_loop

itoa_terminate:
# Write null terminator at the final index
  sb    $zero, 0($t0)           
itoa_end:
  jr    $ra
### itoa end

### clear_buffer start
## args:
##      * a0: input buffer
##      * a1: maximum size of the buffer
## Clears out the entire buffer with zeros
## Returns nothing
clear_buffer:
  move  $t0, $a0     # $t0 = current buffer pointer 
  move  $t1, $a1     # $t1 = size of buffer remaining
  li    $t2, 0

clear_byte:
  beqz  $t1, clear_buffer_done
  nop   
  sb    $t2, 0($t0)
  addi  $t0, $t0, 1
  addi  $t1, $t1, -1
  j     clear_byte
  nop

clear_buffer_done:
  jr $ra
### clear_buffer end

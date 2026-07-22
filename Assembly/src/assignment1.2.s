# This is the 1st Assignment of the Lab
# Part 2) 
#   Take two integers and find the gcd of those numbers
#   Here numbers can be positive, negative or zero

.data
number_1_prompt:  .ascii "Enter the first number: "
number_2_prompt:  .ascii "Enter the second number: "
invalid_prompt:   .ascii "Both numbers are 0. GCD not defined\n"
output:           .ascii "The HCF (GCD) of the two numbers is: "
newline:          .ascii "\n"
in_buf:           .space  16 
out_buf:          .space  16

# syscalls used in this program:
# sys_exit: 4001
#   takes 1 argument:
#     * the exit status of the program      ($a0)
# sys_read: 4003
#   takes 3 arguments:
#     * the input file descriptor           ($a0)
#     * the pointer to the input buffer     ($a1)
#     * size of the input buffer            ($a2)
# sys_write: 4004 
#   takes 3 arguments:
#     * the output file descriptor          ($a0)
#     * the pointer to the output buffer    ($a1)
#     * size of the buffer                  ($a2)

.text
.globl __start

### __start start
__start:
# Write the input prompt for the first number to the screen
  li $v0, 4004
  li $a0, 1
  la $a1, number_1_prompt
  li $a2, 24
  syscall

# Read the first integer value and store to a saved register
  jal read_int
  move $s0, $v0

# Write the input prompt for the second number to the screen
  li $v0, 4004
  li $a0, 1
  la $a1, number_2_prompt
  li $a2, 25
  syscall

# Read the second integer value and store to a saved register
  jal read_int
  move $s1, $v0

# Turn any negative values into positive values as GCD is always positive
  abs $s0, $s0
  abs $s1, $s1

# If s0 is zero check if s1 is zero
  beqz $s0, s0_zero
# If s1 is not zero here, then both values are positive values
# Thus simply calculate the GCD
  bnez $s1, compute_gcd 
# We only come here if only s1 is zero, thus GCD is trivially the value in the s0 register
  move $s2, $s0
  j print_output_prompt

s0_zero:
# If both numbers are zero, the GCD is not defined so give a bad input error
  beqz $s1, both_zero
# We only come here if s0 is zero and s1 is not zero so s1 is the GCD
  move $s2, $s1
  j print_output_prompt

both_zero:
# Print the bad input prompt and then exit the program 
  li $v0, 4004
  li $a0, 1
  la $a1, invalid_prompt
  li $a2, 36
  syscall
# Loading the exit status into the a0 register
  li $a0, 1
  j main_exit

compute_gcd:
# On linux you are supposed to populate a0 ... a3 for arguments to function call
  move $a0, $s0
  move $a1, $s1
  jal calc_gcd
  move $s2, $v0

print_output_prompt:
  li $v0, 4004
  li $a0, 1
  la $a1, output
  li $a2, 37
  syscall

# Printing the output
  move $a0, $s2
  jal print_uint

# Ending with newline
  li $v0, 4004
  li $a0, 1
  la $a1, newline
  li $a2, 1
  syscall

  li $a0, 0

main_exit:
# On linux, the exit syscall requires 1 argument, i.e. the exit status of the program
# 0 means it worked succesfully
# Any other value indicates some kind of failure
  li $v0, 4001
  syscall
### __start end

# Standard GCD algorithm
# Would expect you to understand these on your own
 
### calc_gcd start
calc_gcd:
  move $t0, $a0
  move $t1, $a1
gcd_loop:
  beq $t0, $t1, gcd_end
  bgt $t0, $t1, gcd_sub
swap:
  move $t2, $t0
  move $t0, $t1
  move $t1, $t2
gcd_sub:
  sub $t0, $t0, $t1 
  j gcd_loop
gcd_end:
  move $v0, $t0
  jr $ra
### calc_gcd end

# Helper function to read an it
### read_int start
read_int:
# Reading the buffer to in_buf
  li $v0, 4003
  li $a0, 0
  la $a1, in_buf
  li $a2, 16
  syscall

# Here we store the accumulated value in register v0 (Which the user expects the result to be stored in)
  la $t0, in_buf
  li $v0, 0

# Checking if the buffer starts with a '-' (ascii 45)
  lb $t1, 0($t0)
  bne $t1, 45, atoi_loop
  li $t4, 1
  addi $t0, $t0, 1

# standard conversion from ascii to int
atoi_loop:
# load 1 byte from the buffer, if it is null or '\n' (ascii 10), then end the loop
  lb $t1, 0($t0)
  beq $t1, 10, atoi_end
  beqz $t1, atoi_end

# convert the ascii value to int value
  sub $t1, $t1, 48

# Accumulate this read value
  mul $v0, $v0, 10
  add $v0, $v0, $t1

# increase the index and go back to reading
  addi $t0, $t0, 1
  j atoi_loop

atoi_end:
  beqz $t4, read_int_end
  neg $v0, $v0

read_int_end:
  jr $ra
### read_int end

# Helper function to print an unsigned int
### print_uint start
print_uint:
  la $t0, out_buf
# start at the end of the buffer and build it backwards
# i.e. from lsb to msb
  addi $t0, $t0, 15
# null terminate the buffer
  sb $zero, 0($t0)
  move $t1, $a0

itoa_loop:
  addi $t0, $t0, -1
  li $t2, 10
  div $t1, $t2
  mflo $t1
  mfhi $t3

  addi $t3, $t3, 48
# write the remainder to the buffer
  sb $t3, 0($t0)

# if the is not zero try the loop again
  bnez $t1, itoa_loop

# setting up the write
# moving the start of the buffer to register $a1
  move $a1, $t0
  la $t2, out_buf
  addi $t2, $t2, 16
# Calculating the size of the actual string without the null termination
  sub $a2, $t2, $t0
  addi $a2, $a2, -1

  li $v0, 4004
  li $a0, 1
  syscall 

  jr $ra
### print_uint end

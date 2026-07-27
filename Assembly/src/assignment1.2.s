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
  li $v0, 4003
  li $a0, 0
  la $a1, in_buf
  li $a2, 16
  syscall

  la $a0, in_buf
  li $a1, 16
  jal atoi
  move $s0, $v0

# Write the input prompt for the second number to the screen
  li $v0, 4004
  li $a0, 1
  la $a1, number_2_prompt
  li $a2, 25
  syscall

# Read the second integer value and store to a saved register
  li $v0, 4003
  li $a0, 0
  la $a1, in_buf
  li $a2, 16
  syscall

  la $a0, in_buf
  li $a1, 16
  jal atoi
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
  j __start_exit

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
  la $a0, out_buf
  li $a1, 16
  move $a2, $s2
  jal itoa

  move $a2, $v0
  li $v0, 4004
  li $a0, 1
  la $a1, out_buf
  syscall

# Ending with newline
  li $v0, 4004
  li $a0, 1
  la $a1, newline
  li $a2, 1
  syscall

  li $a0, 0

__start_exit:
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



# This is the 1st Assignment of the Lab
# Part 1) 
#   Take two positive integers and find the gcd of those numbers

# Some semantic info about registers
# $zero       : always stores the value zero
# $v0... $v1  : used to store the return values of function calls
# $a0... $a3  : used as input arguments to function calls
# $t0... $t9  : temporary registers. These registers can be modified by function calls
# $s0... $s7  : saved registers: The values in these registers must be preserved across function calls
# $sp         : stores the stack pointer
# $ra         : stores the address from where function is called
# rest are reserved registers which we won't get into

.data
number_1_prompt:  .ascii "Enter the first number: "
number_2_prompt:  .ascii "Enter the second number: "
output:           .ascii "The HCF (GCD) of the two numbers is: "
newline:          .ascii "\n"
in_buf:           .space  16
out_buf:          .space  16

# syscalls used in this program:
# sys_exit: 4001
#   takes 1 argument:
#     * the exit status of the program
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
  jal read_uint
  move $s0, $v0

# Write the input prompt for the second number to the screen
  li $v0, 4004
  li $a0, 1
  la $a1, number_2_prompt
  li $a2, 25
  syscall

# Read the second integer value and store to a saved register
  jal read_uint
  move $s1, $v0

# Make the call to the calc_gcd function
  move $a0, $s0
  move $a1, $s1
  jal calc_gcd
  move $s2, $v0

# Write the output
  li $v0, 4004
  li $a0, 1
  la $a1, output
  li $a2, 37
  syscall

# Print the integer output value
  move $a0, $s2
  jal print_uint

  li $v0, 4004
  li $a0, 1
  la $a1, newline
  li $a2, 1
  syscall

# exit the program
  li $v0, 4001
  li $a0, 0
  syscall
### __start end

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

### read_uint start
read_uint:
# read the input into the in_buf
  li $v0, 4003
  li $a0, 0
  la $a1, in_buf
  li $a2, 16
  syscall

# Here $v0 stores the accumulated value
  la $t0, in_buf
  li $v0, 0

# standard way to convert ascii to integer
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
# jr jumps back to where function was called from
# This address is stored in the $ra register
# If your function is making other function calls then it
# is advised you store this value somewhere (preferebly on the stack)
# Otherwise you would forget where you came from
  jr $ra

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
# the div assembly takes 2 values and stores the quotient in the lo register
# and the remainder in the hi register
  mflo $t1
  mfhi $t3

# write the remainder to the buffer
  addi $t3, $t3, 48
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

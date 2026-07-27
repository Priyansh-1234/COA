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
# This is a linux specific thing.
# Usually the linker will expect a symbol called __start
# which is the entry point of the program
# This can be changed but depends upon how you can tweak your linker

# The actual start of any program in any ELF file is done through a header
# symbol called e_entry which holds the virtual memory address to the first machine
# instruction the CPU should execute
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
  la $a0, out_buf
  li $a1, 16
  move $a2, $s2
  jal itoa

  move $a2, $v0
  li $v0, 4004
  li $a0, 1
  la $a1, out_buf
  syscall

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
  nop
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

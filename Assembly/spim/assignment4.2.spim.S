# ------------------------------------------------------------
# Name: Priyansh Pranjal
# Roll Number: 24CS10024
# Course: Computer Organization and Architecture Laboratory
# Assignment: MIPS32 Assignment 4
# Question: 2
# Problem: Count set bits using a procedure
# Date: 29-07-2026
# ------------------------------------------------------------

.data
input:      .asciiz    "Enter a non-negative integer N: "
output:     .asciiz    "The number of set bits in N: "
invalid:    .asciiz    "The entered number is negative\n"
newline:    .asciiz    "\n"

.text
.globl main
### main start
main:
# prompting the user for input
    li      $v0, 4
    la      $a0, input
    syscall

# reading the input number
    li      $v0, 5
    syscall
# saving the read number
    move    $s0, $v0

# if the read number is less than zero, then this is an invalid case
    bltz    $s0, main_invalid_input

# setting up register for the function call
    move    $a0, $s0
    jal     count_set_bits
# saving the ouput of the function in s1
    move    $s1, $v0

# printing the output prompt
    li      $v0, 4
    la      $a0, output
    syscall

# printing the count of set bits
    li      $v0, 1
    move    $a0, $s1
    syscall

    li      $v0, 4
    la      $a0, newline
    syscall

# exiting
    j main_exit

main_invalid_input:
# handling the invalid input with a prompt and then exiting
    li      $v0, 4
    la      $a0, invalid
    syscall

    li      $v0, 4
    la      $a0, newline
    syscall

main_exit:
    li      $v0, 10
    syscall
### main end

### count_set_bits start
## args:
##      $a0: number whose bits need to be counted
##      user contract for the number to be non negative
## returns:
##      $v0: the count of set bits in input
count_set_bits:
# $t0 contains the count of set bits
# $t1 contains the current number
    li      $t0, 0
    move    $t1, $a0

count_set_bits_loop:
# if the current number is zero then we are done
    beqz    $t1, count_set_bits_return
    nop
    
# otherwise check the lsb for 1
    andi    $t2, $t1, 1
    beqz    $t2, count_set_bits_shift 
    nop 

# the bit was non zero so add 1 to the running count
    addi    $t0, $t0, 1

count_set_bits_shift:
# shift the current number to the right
    srl     $t1, $t1, 1
    j count_set_bits_loop

count_set_bits_return:
    move    $v0, $t0
    jr      $ra
### count_set_bits end
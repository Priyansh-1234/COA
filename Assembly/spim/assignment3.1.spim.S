# ------------------------------------------------------------
# Name: Priyansh Pranjal
# Roll Number: 24CS10024
# Course: Computer Organization and Architecture Laboratory
# Assignment: MIPS32 Assignment 3
# Problem: Adding Digits in a String
# Date: 27-07-2026
# ------------------------------------------------------------

.data
prompt: .asciiz "Enter the string: "
output: .asciiz "The sum of digits is: "
newline: .asciiz "\n"
buffer: .space 32

.text
.globl main
main:
    li $v0, 4
    la $a0, prompt
    syscall

    li $v0, 8
    la $a0, buffer
    li $a1, 32
    syscall

# start at the start of the buffer 
    la $t0, buffer
# start the accumulator with 0
    li $t1, 0

add_digits: 
# load one byte from the buffer and if it is null terminated
# or it is newline terminated # then terminate
    lb $t2, 0($t0)
    beqz $t2, done
    beq $t2, 10, done

# if it is not a digit then ignore it
    blt $t2, 48, non_digit
    bgt $t2, 57, non_digit


# get the value of the digit
    addi $t3, $t2, -48
    add $t1, $t1, $t3

# add the value of the digit to the accumulator
# and then increment the place where t0 is pointing to
    addi $t0, $t0, 1
    j add_digits

# just increment the t0 pointer to the next byte
non_digit:
    addi $t0, $t0, 1
    j add_digits

done: 
# write the prompt
    li $v0, 4
    la $a0, output
    syscall
    
# write the number
    move $a0, $t1
    li $v0, 1
    syscall

# write the number
    li $v0, 4
    la $a0, newline
    syscall

    j exit

# exit the program gracefully
exit:
    li $v0, 10
    syscall
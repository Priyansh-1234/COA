# ------------------------------------------------------------
# Name: Priyansh Pranjal
# Roll Number: 24CS10024
# Course: Computer Organization and Architecture Laboratory
# Assignment: MIPS32 Assignment 2
# Problem: LCM using repeated addition
# Date: 22-07-2026
# ------------------------------------------------------------

.data
prompt1: #prompt user to enter the numbers
    .asciiz "Enter the first number: "

prompt2:
    .asciiz "Enter the second number: "

output: #output message
    .asciiz "The LCM of the two numbers is: "

bad_input:
    .asciiz "Error: Both inputs must be positive integers\n"

.text
.globl main
main:
    #printing the message for entering first number
    la $a0,prompt1 
    # which operation or service the OS should perform...
    li $v0,4 
    syscall

    #reading the first number and storing it in register $t0
    li $v0,5 
    syscall
    move $t0,$v0

    #printing the message for entering second number
    la $a0,prompt2 
    li $v0,4
    syscall

    li $v0,5 #reading the second number and storing it in register $t1
    syscall
    move $t1,$v0

    # Checking that both the numbers are positive values
    blez $t0, not_pos_branch
    blez $t1, not_pos_branch

    # moving the original values to registers t2, t3
    move $t2, $t0
    move $t3, $t1

lcm_loop:
    # if the registers t2 and t3 are equal then we have found our lcm so jump to finish
    beq $t2, $t3, finish
    # if the register t2 is less then increase the value in register t2
    blt $t2, $t3, t2_less

    # automatically fall through if t3 < t2 then increase the value at t3
t3_less:
    # increasing the value in t3 register
    add $t3, $t3, $t1
    b lcm_loop

t2_less:
    # increasing the value in t2 register
    add $t2, $t2, $t0
    b lcm_loop

finish:
    # printing the finish prompt
    li $v0, 4
    la $a0, output
    syscall

    # printing the lcm value could be either in t2 or t3
    # picked t2 cause yay
    li $v0, 1
    move $a0, $t2
    syscall
    b exit

not_pos_branch:
    # if either of the two numbers wasn't positive we jump to this label
    # here we print a bad input prompt and the exit
    li $v0, 4
    la $a0, bad_input
    syscall
    b exit

exit:
    # Exits the program
    li $v0, 10
    syscall

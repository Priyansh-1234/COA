# ------------------------------------------------------------
# Name: Priyansh Pranjal
# Roll Number: 24CS10024
# Course: Computer Organization and Architecture Laboratory
# Assignment: MIPS32 Assignment 1
# Problem: GCD using repeated subtraction
# Date: 22-07-2026
# ------------------------------------------------------------

.data #data segment

prompt1: #prompt user to enter the numbers
    .asciiz "Enter the first number\n"

prompt2:
    .asciiz "Enter the second number\n"

output: #output message
    .asciiz "The HCF (GCD) of the two numbers is: "

bad_input:
    .asciiz "Both of the two numbers are zero\n"

newline: #newline
.asciiz "\n"

.text #code starts here
.globl main
main:

    la $a0,prompt1 #printing the message for entering first number
    li $v0,4 # which operation or service the OS should perform...
    syscall

    li $v0,5 #reading the first number and storing it in register $t0
    syscall
    abs $t0, $v0

    la $a0,prompt2 #printing the message for entering second number
    li $v0,4
    syscall

    li $v0,5 #reading the second number and storing it in register $t1
    syscall
    abs $t1, $v0
    beqz $t0, possible_zero_case
    beqz $t1, zero_case

gcd:
    beq		$t0, $t1, finish	# if $t0 == $t1 then goto finish
    bgt     $t0, $t1, subtract
    

swap:
    move $t3, $t0
    move $t0, $t1
    move $t1, $t3
    
subtract:
    sub $t0, $t0, $t1
    b gcd

finish:
    li $v0, 4
    la $a0, output
    syscall
    move $a0, $t0
    li $v0, 1
    syscall
    b exit

possible_zero_case:
    beqz $t1, incorrect
    move $t0, $t1
    b zero_case

incorrect:
    la $a0, bad_input
    li $v0, 4
    syscall
    b exit

zero_case:
    li $v0, 4
    la $a0, output
    syscall
    li $v0, 1
    move $a0, $t0
    syscall
    b exit

exit:
    li $v0, 10
    syscall
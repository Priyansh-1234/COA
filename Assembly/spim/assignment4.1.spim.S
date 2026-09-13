# ------------------------------------------------------------
# Name: Priyansh Pranjal
# Roll Number: 24CS10024
# Course: Computer Organization and Architecture Laboratory
# Assignment: MIPS32 Assignment 4
# Question: 1
# Problem: Prime-number test using a procedure
# Date: 29-07-2026
# ------------------------------------------------------------

.data
input:              .asciiz "Enter an integer greater than 1: "
error:              .asciiz "Error: The input must be an integer greater than 1."
prime_output:       .asciiz " is a prime number."
non_prime_output:   .asciiz " is not a prime number."
newline:            .asciiz "\n"
.text

.globl main
### main start
main: 
    li      $v0, 4
    la      $a0, input
    syscall

    li      $v0, 5
    syscall

# storing the read integer into a saved register so it doesn't get destroyed by function call
    move    $s0, $v0
    blt     $s0, 2, main_error_branch
    nop 

# setting up the registers for the function call and storing the result in a saved register
    move    $a0, $s0
    jal     is_prime
    move    $s1, $v0

# printing the number first
    li      $v0, 1
    move    $a0, $s0
    syscall 

# depending upon the result of the function call, print either prime or not prime so setting up the jump
    beqz    $s1, main_non_prime
    nop 

# prime branch
# just printing the output prompt and newline and exiting
    li      $v0, 4
    la      $a0, prime_output
    syscall

    li      $v0, 4
    la      $a0, newline
    syscall

    j main_exit

# just printing the non prime output prompt and newline and exiting
main_non_prime:
    li      $v0, 4
    la      $a0, non_prime_output
    syscall

    li      $v0, 4
    la      $a0, newline
    syscall

    j main_exit

# is case of error printing an apt error prompt and exiting
main_error_branch:
    li      $v0, 4
    la      $a0, error
    syscall

    li      $v0, 4
    la      $a0, newline
    syscall

    j main_exit

main_exit:
    li $v0, 10
    syscall
### main end

### is_prime start
## Args: 
##      $a0: inupt number. Must be greater than or equal to 2.
##      The function makes no checks, thus if faulty input is passed,
##      the fault lies at the hands of the caller
## Returns:
##      $v0: 0 is not prime and 1 if prime
is_prime:
    move $t0, $a0

    beq $t0, 2, is_prime_found_prime
    nop

    li $t1, 2

is_prime_loop:
    ble $t0, $t1, is_prime_found_prime
    nop

    move $t2, $t0

is_prime_sub_loop:
    bltz $t2, is_prime_continue
    nop

    beqz $t2, is_prime_not_prime
    nop

    sub $t2, $t2, $t1
    j is_prime_sub_loop

is_prime_continue:
    addi $t1, $t1, 1
    j is_prime_loop

is_prime_not_prime:
    li $v0, 0
    j is_prime_done

is_prime_found_prime: 
    li $v0, 1

is_prime_done:
    jr $ra

### is_prime end
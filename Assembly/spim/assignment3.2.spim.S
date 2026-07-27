# ------------------------------------------------------------
# Name: Priyansh Pranjal
# Roll Number: 24CS10024
# Course: Computer Organization and Architecture Laboratory
# Assignment: MIPS32 Assignment 3
# Problem: Encoding strings
# Date: 27-07-2026
# ------------------------------------------------------------

.data
input: .asciiz "Enter the string: "
terminate: .asciiz "terminate (Y/N): "
output: .asciiz "Your encoded string is: "
exit_prompt: .asciiz "Done."
newline: .asciiz "\n"

#stores the input
input_buffer: .space 32
#stores the output
output_buffer: .space 32

# creating a lookup table
# alignment is important as words should be word aligned
# otherwise could lead to crash or slower reads depending 
# on architecture
.align 4
table: .word 4 6 9 5 0 3 1 8 7 2

.text
.globl main
main: 

ask_input:
# ask for the input
    li $v0, 4
    la $a0, input
    syscall

    li $v0, 8
    la $a0, input_buffer
    li $a1, 32
    syscall

# incase the user wrote more things, null terminate the 
# input buffer
    la $t0, input_buffer
    li $t1, 0
    sb $t1, 31($t0)

    la $t0, input_buffer
    la $t1, output_buffer

encode:
    lb $t2, 0($t0)
# if the byte is '\n' or null terminator the exit copying bytes
    beqz $t2, copy_finish 
    beq $t2, 10, copy_finish

# if the byte is not a digit just directly copy
    blt $t2, 48, non_digit
    bgt $t2, 57, non_digit

# calculate the value of the number character
    addi $t4, $t2, -48
# finding index in the lookup table
# the index is the (value stored * 4)th byte position
# hence the left shift
    sll $t4, $t4, 2
    la $t5, table
    add $t5, $t5, $t4
    lw $t6, 0($t5)

# then compute the character of the encoded digit
    addi $t3, $t6, 48
    j copy_not_finish

non_digit:
    move $t3, $t2

copy_not_finish:
# copy the byte into the output buffer
    sb $t3, 0($t1)

# increment both pointer and start encoding again
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j encode

copy_finish:
# we are done so just copy the newline or null terminator to the output buffer
    sb $t2, 0($t1)
    j done

# write the output
done:
    li $v0, 4
    la $a0, output
    syscall

    li $v0, 4
    la $a0, output_buffer
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    la $t0, output_buffer
    li $t1, 31
    li $t2, 0

# cleanup the output buffer
# so stale input is not present
cleanup:
    sb $t2, 0($t0)
    addi $t0, $t0, 1
    addi $t1, $t1, -1
    bnez $t1 cleanup 

    j ask_terminate

# ask the user for continuation
ask_terminate:
    li $v0, 4
    la $a0, terminate
    syscall

    li $v0, 8
    la $a0, input_buffer
    li $a1, 32
    syscall

    la $t0, input_buffer
    lb $t1, 0($t0)

# if the first byte is 'Y' or 'y' then go back to ask input
# else finish the program
    beq $t1, 89, program_finish
    beq $t1, 121, program_finish
    j ask_input

program_finish:
    li $v0, 4
    la $a0, exit_prompt
    syscall

exit:
    li $v0, 10
    syscall
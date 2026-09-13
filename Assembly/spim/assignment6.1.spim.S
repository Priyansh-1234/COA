# ------------------------------------------------------------
# Group Number: 62
# Group Members (Name and Roll Number):
# 1. Priyansh Pranjal     24CS10024
# 2. Allu Gowri Sasaank   24CS10054
# Course: Computer Organization and Architecture Laboratory
# Assignment: MIPS32 Assignment 6
# Question: 1
# Problem: Postfix expression evaluation using an explicit stack
# Date: 5-8-2026
# ------------------------------------------------------------

.data
input_prompt:       .asciiz "Enter a postfix expression: "
output_prompt:      .asciiz "The evaluated result is: "
malformed_prompt:   .asciiz "Error: malformed postfix expression\n"
invalid_prompt:     .asciiz "Error: invalid token in the expression.\n"
overflow_prompt:    .asciiz "Error: explicit operand stack overflow.\n"
div_by_zero_prompt: .asciiz "Error: division by zero.\n"
newline:            .asciiz "\n"
input:              .space 82
# Aligning the stack to word alignment
                    
operand_stack:             .word 0 : 20

.text
.globl main
# NOTES:
#       each operand (0-9)
#       valid operators (+ - / *)
#       total input length (80 characters)
#       presentable in signed int
#       stack top maintained as (top = -1 then empty otherwise there is content)

### main start
main:
    li      $v0, 4
    la      $a0, input_prompt
    syscall

    li      $v0, 8
    la      $a0, input
    li      $a1, 80
    syscall

    la      $a0, input
    la      $a1, operand_stack
    li      $a2, 20
    jal     evaluate_postfix

    move    $s0, $v0

    beq     $v1, 1, main_malformed_input
    beq     $v1, 2, main_invalid_input
    beq     $v1, 3, main_stack_overflow
    beq     $v1, 4, main_div_by_zero

    li      $v0, 4
    la      $a0, output_prompt
    syscall

    li      $v0, 1
    move    $a0, $s0
    syscall

    li      $v0, 4
    la      $a0, newline
    syscall

    j       main_exit

main_malformed_input:
    li      $v0, 4
    la      $a0, malformed_prompt
    syscall

    j       main_exit
main_invalid_input:
    li      $v0, 4
    la      $a0, invalid_prompt
    syscall

    j       main_exit
main_stack_overflow:
    li      $v0, 4
    la      $a0, overflow_prompt
    syscall

    j       main_exit
main_div_by_zero:
    li      $v0, 4
    la      $a0, div_by_zero_prompt
    syscall

    j       main_exit

main_exit:
    li      $v0, 10
    syscall
### main end

### evaluate_postfix start
##      $a0: postfix expression base address
##      $a1: operand stack base address
##      $a2: stack capacity
## returns:
##      $v0: new top index
##      $v1:    0 on success
##              1 on malformed input
##              2 on invalid character or operand
##              3 on stack overflow
##              4 on Div by zero
evaluate_postfix:
# Saving the saved registers and the return address
    addi    $sp, $sp, -36
    sw      $s0, 32($sp)
    sw      $s1, 28($sp)
    sw      $s2, 24($sp)
    sw      $s3, 20($sp)
    sw      $s4, 16($sp)
    sw      $s5, 12($sp)
    sw      $s6, 8($sp)
    sw      $s7, 4($sp)
    sw      $ra, 0($sp)

    move    $s0, $a0
    move    $s1, $a1
    move    $s2, $a2
    lb      $s3, 0($s0)
    li      $s5, -1
evaluate_postfix_main_loop:
# Checking if null terminated or \n terminated
    beqz    $s3, evaluate_postfix_main_loop_finish
    beq     $s3, 0xA, evaluate_postfix_main_loop_finish

# Skipping the spaces
    beq     $s3, 0x20, evaluate_postfix_main_loop_continue

# Checking for digit
    blt     $s3, 0x30, evaluate_postfix_main_loop_operator
    bgt     $s3, 0x39, evaluate_postfix_main_loop_operator

# This is a digit so we get the digit value and push to the stack
    andi    $s4, $s3, 0xF
    move    $a0, $s1
    move    $a1, $s5
    move    $a2, $s2
    move    $a3, $s4
    jal     push

# Handling overflow
    beq     $v1, 1, evaluate_postfix_overflow

# Continuing the loop
    move    $s5, $v0
    j       evaluate_postfix_main_loop_continue

evaluate_postfix_main_loop_operator:
# Popping top value
    move    $a0, $s1
    move    $a1, $s5
    jal     pop

# Handling malformed input
    beq     $v1, -2, evaluate_postfix_malformed_input
    move    $s5, $v1
    move    $s4, $v0

# Popping second value
    move    $a0, $s1
    move    $a1, $s5
    jal     pop

# Handling malformed input
    beq     $v1, -2, evaluate_postfix_malformed_input
    move    $s5, $v1
    move    $s6, $v0

# Applying the operator
    move    $a0, $s6
    move    $a1, $s4
    move    $a2, $s3
    jal     apply_operator

# Divide by zero error
    beq     $v1, 1, evaluate_postfix_div_zero
# Invalid operator
    beq     $v1, 2, evaluate_postfix_invalid_token

# Pushing the result back to the stack
    move    $a0, $s1
    move    $a1, $s5
    move    $a2, $s2
    move    $a3, $v0
    jal     push

# Checking for overflow
    beq     $v1, 1, evaluate_postfix_overflow

# Continuing the loop
    move    $s5, $v0
    j       evaluate_postfix_main_loop_continue


evaluate_postfix_main_loop_continue:
# Incrementing the current byte by 1
    addi    $s0, $s0, 1
    lb      $s3, 0($s0)
    j       evaluate_postfix_main_loop

evaluate_postfix_main_loop_finish:
# Popping one value from the stack
# If the current top after pop is -1 then perfect
# otherwise malformed input
    move    $a0, $s1
    move    $a1, $s5
    jal     pop

# Checking for underflow
    beq     $v1, -2, evaluate_postfix_malformed_input
    move    $s5, $v1

# Checking if stack still has items
    bne     $s5, -1, evaluate_postfix_malformed_input
    li      $v1, 0
    j       evaluate_postfix_exit

evaluate_postfix_overflow:
    li      $v1, 3
    j       evaluate_postfix_exit

evaluate_postfix_malformed_input:
    li      $v1, 1
    j       evaluate_postfix_exit

evaluate_postfix_div_zero:
    li      $v1, 4
    j       evaluate_postfix_exit

evaluate_postfix_invalid_token:
    li      $v1, 2
    j       evaluate_postfix_exit


evaluate_postfix_exit:
# Restoring the saved registers and the return address
    lw      $s0, 32($sp)
    lw      $s1, 28($sp)
    lw      $s2, 24($sp)
    lw      $s3, 20($sp)
    lw      $s4, 16($sp)
    lw      $s5, 12($sp)
    lw      $s6, 8($sp)
    lw      $s7, 4($sp)
    lw      $ra, 0($sp)
    addi    $sp, $sp, 36

    jr $ra
### evaluate_postfix end

### push start
## args:
##      $a0: operand stack base address
##      $a1: current top index
##      $a2: stack capacity
##      $a3: value to be pushed 
## returns:
##      $v0: new top index
##      $v1: success code (0 on success 1 on failure)
push:
# Checking for overflow
    addi    $t0, $a1, 1
    beq     $t0, $a2, push_stack_full

# Calculating the byte address where the int would go (base + (current_top_index + 1) * 4)
    move    $t1, $a0
    addi    $t2, $a1, 1
    sll     $t2, $t2, 2
    add     $t3, $t1, $t2

# Storing the value at the calculated address
    move    $t4, $a3
    sw      $t4, 0($t3)

# Storing back the new top index and success code
    move    $v0, $t0
    li      $v1, 0
    j       push_exit

push_stack_full:
# Stack top hasn't changed and the push failed
    move    $v0, $a1
    li      $v1, 1
    j       push_exit

push_exit:
    jr      $ra
### push end

### pop start
## args:
##      $a0: operand stack base address
##      $a1: current top index
## returns:
##      $v0: popped value from the stack
##      $v1: current top index on success and -2 on failure
pop:
# Checking if the stack is empty
    move    $t0, $a1
    beq     $t0, -1, pop_stack_empty

# Calculating the address of the top element
    move    $t1, $a0
    move    $t2, $a1
    sll     $t2, $t2, 2
    add     $t3, $t1, $t2

# Loading the top element and calculating the new current_top_index
    lw      $v0, 0($t3)
    move    $v1, $a1
    addi    $v1, $v1, -1

# Exiting from the function
    j pop_exit
pop_stack_empty:
    li      $v1, -2
    j       pop_exit
pop_exit:
    jr      $ra

### pop end

### apply_operator start
## args:
##      $a0: Left operand
##      $a1: Right operand
##      $a2: Ascii of the operator
## returns:
##      $v0: Arithemetic result on success
##      $v1: 0 on success; 1 on div by zero; 2 on invalid operator
apply_operator:
# Jumping to the correct operator otherwise saying invalid operator
    beq     $a2, 0x2B, apply_operator_add
    nop
    beq     $a2, 0x2D, apply_operator_sub
    nop
    beq     $a2, 0x2A, apply_operator_mul
    nop
    beq     $a2, 0x2F, apply_operator_div
    nop
    j       apply_operator_invalid_op

# Simply add (no chance of failure)
apply_operator_add:
    add     $v0, $a0, $a1
    li      $v1, 0
    j       apply_operator_exit

# Simply subtract (no chance of failure)
apply_operator_sub:
    sub     $v0, $a0, $a1
    li      $v1, 0
    j       apply_operator_exit

# Simply multiply (no chance of failure) (The problem statement said 32 bit int is sufficient so using 
# only the lower 32 bits of mult (mul) is sufficient)
apply_operator_mul:
    mul     $v0, $a0, $a1
    li      $v1, 0
    j       apply_operator_exit

# Checking if the divisor is zero
# If divisor is valid then storing only the quotient
apply_operator_div:
    beqz    $a1, apply_operator_div_zero
    div     $a0, $a1
    mflo    $v0
    li      $v1, 0
    j apply_operator_exit

apply_operator_div_zero:
    li      $v1, 1
    j apply_operator_exit

apply_operator_invalid_op:
    li      $v1, 2
    j       apply_operator_exit

apply_operator_exit:
    jr      $ra
### apply_operator end

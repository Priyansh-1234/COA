.data
number_1_prompt:  .ascii "Enter the first number: "
number_2_prompt:  .ascii "Enter the second number: "
invalid_prompt:   .ascii "Either of the numbers in not positive\n"
newline:          .ascii "\n"
output:           .ascii "The LCM of the two numbers is: "
in_buf:           .space 16
out_buf:          .space 16

.text
.globl __start
### __start start
__start:
  li $v0, 4004
  li $a0, 1
  la $a1, number_1_prompt
  li $a2, 24
  syscall

# Reading the first integer
  jal read_int
  move $s0, $v0

  li $v0, 4004
  li $a0, 1
  la $a1, number_2_prompt
  li $a2, 25
  syscall

# Reading the second integer
  jal read_int
  move $s1, $v0

  blez $s0, invalid_input
  blez $s1, invalid_input

print_output:
  li $v0, 4004
  li $a0, 1
  la $a1, output
  li $a2, 31
  syscall

# setting up the registers to call fn calc_lcm
  move $a0, $s0
  move $a1, $s1
  jal calc_lcm
  move $s2, $v0

  move $a0, $s2
  jal print_uint

  li $v0, 4004
  li $a0, 1
  la $a1, newline
  li $a2, 1
  syscall

  li $a0, 0
  j __start_exit

invalid_input:
  li $v0, 4004
  li $a0, 1
  la $a1, invalid_prompt
  li $a2, 38

  li $a0, 1
  j __start_exit

__start_exit:
  li $v0, 4001
  syscall
### __start end

# algorithm goes as follows:
# calculate the multiples of first number (call n)
# so n, 2n, 3n, ...
# similarly for the other number (call m)
# m, 2m, 3m
# Then just find the minimum value appearing in both lists
### calc_lcm start
calc_lcm:
  move $t0, $a0
  move $t1, $a1

  move $t2, $a0
  move $t3, $a1
lcm_loop:
# if both accumulators i.e. multiple of t0 and t1 are same
# then finish
# otherwise increase the lower valued register
  beq $t2, $t3, lcm_finish
  bgt $t2, $t3, increment_t3

increment_t2:
  add $t2, $t2, $t0
  j lcm_loop

increment_t3:
  add $t3, $t3, $t1
  j lcm_loop

lcm_finish:
  move $v0, $t2
  jr $ra
### calc_lcm end

### read_int start
read_int:
# Reading the buffer to in_buf
  li $v0, 4003
  li $a0, 0
  la $a1, in_buf
  li $a2, 16
  syscall

# Here we store the accumulated value in register v0 (Which the user expects the result to be stored in)
  la $t0, in_buf
  li $v0, 0

# Checking if the buffer starts with a '-' (ascii 45)
  lb $t1, 0($t0)
  bne $t1, 45, atoi_loop
  li $t4, 1
  addi $t0, $t0, 1

# standard conversion from ascii to int
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
  beqz $t4, read_int_end
  neg $v0, $v0

read_int_end:
  jr $ra
### read_int end

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
  mflo $t1
  mfhi $t3

  addi $t3, $t3, 48
# write the remainder to the buffer
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
### print_uint end

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
  li $v0, 4003
  li $a0, 0
  la $a1, in_buf
  li $a2, 16
  syscall

  la $a0, in_buf
  li $a1, 16
  jal atoi
  move $s0, $v0

  li $v0, 4004
  li $a0, 1
  la $a1, number_2_prompt
  li $a2, 25
  syscall

# Reading the second integer
  li $v0, 4003
  li $a0, 0
  la $a1, in_buf
  li $a2, 16
  syscall

  la $a0, in_buf
  li $a1, 16
  jal atoi
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



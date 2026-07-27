# Problem statement:
# Take an input string from the user and add all the 
# digits and print the output

.data
input:    .ascii "Enter the string: "         // 18
output:   .ascii "The sum of digits is: "     // 22
newline:  .ascii "\n"
buffer:   .space 32

.text
.globl __start 

### __start start
__start:
  li $v0, 4004
  li $a0, 1
  la $a1, input
  li $a2, 18
  syscall

  li $v0, 4003
  li $a0, 0
  la $a1, buffer
  li $a2, 32
  syscall

  la $t0, buffer
  li $t1, 32
  li $s0, 0

sum_loop:

  beqz  $t1, done
  nop
  lb    $t3, 0($t0)

  beqz  $t3, done
  nop

  beq   $t3, 10, done
  nop

  blt   $t3, 48, move_forward 
  nop

  bgt   $t3, 57, move_forward
  nop

  andi  $t4, $t3, 0x0F
  add   $s0, $s0, $t4

move_forward:
  addi  $t0, $t0, 1
  addi  $t1, $t1, -1

  j sum_loop
  nop

done:
  li $v0, 4004
  li $a0, 1
  la $a1, output
  li $a2, 22
  syscall

  la $a0, buffer
  li $a1, 32
  jal clear_buffer

  la $a0, buffer
  li $a1, 32
  move $a2, $s0
  jal itoa

  move $a2, $v0
  li $v0, 4004
  li $a0, 1
  la $a1, buffer
  syscall

  li $v0, 4004
  li $a0, 1
  la $a1, newline
  li $a2, 1
  syscall

  li $v0, 4001
  li $a0, 0
  syscall
### __start end

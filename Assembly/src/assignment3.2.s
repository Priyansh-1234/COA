# Problem Statement: Given a string encode the digits present in the string
# Encoding:   0 1 2 3 4 5 6 7 8 9
#             4 6 9 5 0 3 1 8 7 2

.data
input:              .ascii "Enter the string: "       // 18
output:             .ascii "The encoded string is: "  // 23
terminate_prompt:   .ascii "Terminate (Y/N): "        // 17
newline:            .ascii "\n"
done_prompt:        .ascii "done\n"

table:              .ascii "4695031872"
input_buffer:       .space 32
output_buffer:      .space 32

.text
.globl __start
### __start start 
__start:

ask_input:
  li    $v0, 4004
  li    $a0, 1
  la    $a1, input
  li    $a2, 18
  syscall

  li    $v0, 4003
  li    $a0, 0
  la    $a1, input_buffer
  li    $a2, 32
  syscall

  la    $t0, input_buffer
  la    $t1, output_buffer
  li    $t2, 32

encode:
  beqz  $t2, done
  nop

  lb    $t3, 0($t0)
  move  $t4, $t3
  blt   $t3, 48, copy 
  nop
  bgt   $t3, 57, copy
  nop

digit:
  andi  $t5, $t3, 0x0F
  la    $t6, table
  add   $t6, $t6, $t5
  lb    $t4, 0($t6)

copy:
  sb    $t4, 0($t1)
  addi  $t0, $t0, 1
  addi  $t1, $t1, 1
  addi  $t2, $t2, -1

  j encode
  nop
  
done:
  li    $v0, 4004
  li    $a0, 1
  la    $a1, output
  li    $a2, 23
  syscall

  li    $v0, 4004
  li    $a0, 1
  la    $a1, output_buffer
  li    $a2, 32
  syscall

  li    $v0, 4004
  li    $a0, 1
  la    $a1, newline 
  li    $a2, 1
  syscall

  la    $a0, input_buffer
  li    $a1, 32
  jal clear_buffer

  la    $a0, output_buffer
  li    $a1, 32
  jal clear_buffer

ask_terminate:
  li $v0, 4004
  li $a0, 1
  la $a1, terminate_prompt
  li $a2, 17
  syscall

  li $v0, 4003
  li $a0, 0
  la $a1, input_buffer
  li $a2, 32
  syscall

  la $t0, input_buffer
  lb $s0, 0($t0)

  la $a0, input_buffer
  li $a1, 32
  jal clear_buffer

  beq $s0, 0x59, terminate
  nop
  beq $s0, 0x79, terminate
  nop
  j ask_input

terminate:
  li $v0, 4004
  li $a0, 1
  la $a1, done_prompt
  li $a2, 5
  syscall

  li $v0, 4001
  li $a0, 0
  syscall
### __start end

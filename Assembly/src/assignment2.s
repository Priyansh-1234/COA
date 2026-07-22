.data
number_1_prompt:  .ascii "Enter the first number: "
number_2_prompt:  .ascii "Enter the second number: "

.text
.globl __start
__start:
  li $v0, 4004
  li $a0, 1
  la $a1, 24

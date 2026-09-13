# ------------------------------------------------------------
# Group Number: 62
# Group Members (Name and Roll Number):
# 1. Priyansh Pranjal     24CS10024
# 2. Allu Gowri Sasaank   24CS10054
# Course: Computer Organization and Architecture Laboratory
# Assignment: MIPS32 Assignment 6
# Question: 2
# Problem: Run-length encoding, decoding, and verification
# Date: 5-8-2026
# ------------------------------------------------------------

.data
input_prompt:           .asciiz "Enter an uppercase string: "
encoded_prompt:         .asciiz "Encoded string: "
decoded_prompt:         .asciiz "Decoded string: "
verification_prompt:    .asciiz "Verification successful: decoded string matches the original.\n"
unequal_strings_error:  .asciiz "Error: original and decoded strings didn't match.\n"
malformed_error:        .asciiz "Error: malformed run-length encoded string.\n"
buffer_overflow_error:  .asciiz "Error: output buffer capacity exceeded.\n"
invalid_input_error:    .asciiz "Error: enter 1 to 50 uppercase letters only.\n"
newline:                .asciiz "\n"
original:               .space 52
encoded:                .space 128
decoded:                .space 52

.text
.globl main
### main start
main:
# Asking the user for the input
  li      $v0, 4
  la      $a0, input_prompt
  syscall 

# Reading the input
  li      $v0, 8
  la      $a0, original
  li      $a1, 52
  syscall 

# validating the input to be only uppercase characters 50 in size
  la      $a0, original
  li      $a1, 50
  jal     validate_input

# Handling invalid input 
  bnez    $v0, main_invalid_input
  nop

# Encoding the input string
  la      $a0, original
  la      $a1, encoded
  li      $a2, 128
  jal     encode_rle

# Checking for errors during the encoding
  beq     $v1, 1, main_invalid_input
  nop     
  beq     $v1, 2, main_buffer_overflow
  nop 

  move    $s0, $v0

# Writing the encoded string to the user
  li      $v0, 4
  la      $a0, encoded_prompt
  syscall 

  li      $v0, 4
  la      $a0, encoded
  syscall

  li      $v0, 4
  la      $a0, syscall

# Decoding the encoded string
  la      $a0, encoded
  la      $a1, decoded
  li      $a2, 52
  jal     decode_rle

# Checking for errors during decoding
  beq     $v1, 1, main_malformed_encode
  nop 
  beq     $v1, 2, main_buffer_overflow
  nop

  move    $s1, $v0

# Printing the decoded string to the user
  li      $v0, 4
  la      $a0, decoded_prompt
  syscall

  li      $v0, 4
  la      $a0, decoded
  syscall 

  li      $v0, 4
  la      $a0, newline
  syscall 

# Comparing the original and decoded string
  la      $a0, original 
  la      $a1, decoded
  jal     compare_strings

# If the original and decoded strings don't match then logging that
  beqz    $v0, main_non_equal_strings

# Printing the verification
  li      $v0, 4
  la      $a0, verification_prompt
  syscall

  j       main_exit

main_non_equal_strings:
  li      $v0, 4
  la      $a0, unequal_strings_error
  syscall

  j       main_exit
main_malformed_encode: 
  li      $v0, 4
  la      $a0, malformed_error
  syscall 

  j       main_exit
main_buffer_overflow: 
  li      $v0, 4
  la      $a0, buffer_overflow_error
  syscall 

  j       main_exit

main_invalid_input:
  li      $v0, 4
  la      $a0, invalid_input_error
  syscall 

  j       main_exit

main_exit:
  li      $v0, 10
  syscall
### main end

### validate start
# args:
#       $a0: original string address
#       $a2: original string size
# returns: 
#       $v0: 0 on valid input, 1 on failure
validate_input:
  move    $t0, $a0
  move    $t1, $a1

validate_input_loop:
# If the buffer is finished and we didn't find any issue then it is valid
  beqz    $t1, validate_input_finish
  nop

  lb      $t2, 0($t0)

# If the buffer ended with null terminator or \n, then also it was valid
  beqz    $t2, validate_input_finish
  nop
  beq     $t2, 10, validate_input_finish
  nop

# We don't find an upper-case character => invalid input
  blt     $t2, 0x41, validate_input_failure
  bgt     $t2, 0x5A, validate_input_failure

# Incrementing the input pointer and decrementing the size
  addi    $t0, $t0, 1
  addi    $t1, $t1, -1

# Go back to validating
  j       validate_input_loop

validate_input_failure:
  li      $v1, 1
  j       validate_input_exit

validate_input_finish:
  li      $v0, 0
  j       validate_input_exit

validate_input_exit:
  jr      $ra
### validate end

### encode_rle start
# args:
#       $a0: original string address
#       $a1: encoded buffer address 
#       $a2: encoded buffer capacity
# returns: 
#       $v0: encoded length excluding null terminator
#       $v1: 0 on success; 1 for invalid original input; 2 for encoded buffer overflow
encode_rle:
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

encode_rle_main_loop:
# load the first byte of the input buffer
  lb      $s4, 0($s0)
  beqz    $s4, encode_rle_main_finish

# If the character isn't in [A-Z] then its is an invalid input
  blt     $s4, 0x41, encode_rle_invalid
  nop

  bgt     $s4, 0x5A, encode_rle_invalid
  nop 

# Store the length of the running character
  li      $s6, 0

encode_rle_sub_loop:
# If the current character and the running character isn't the same then terminate inner loop
  lb      $s5, 0($s0)
  bne     $s4, $s5, encode_rle_sub_finish

# The characters matched
# increment the length of running character and input pointer by 1
  addi    $s6, $s6, 1
  addi    $s0, $s0, 1
  j       encode_rle_sub_loop

encode_rle_sub_finish:
# If the buffer is finshed we can't write the encoding
  beqz    $s2, encode_rle_buffer_complete

# Store the running character
  sb      $s4, 0($s1)
  
# Increment the pointer and decrement the size of the output buffer
  addi    $s1, $s1, 1
  addi    $s2, $s2, -1

# Write the unsigned integer to the buffer
  move    $a0, $s0
  move    $a1, $s2
  move    $a2, $s6
  jal     utoa   

# If the writing uint failed then buffer was complete
  bne     $v1, encode_rle_buffer_complete

# Increment the output buffer pointer and decrement remaining size of buffer
  add     $s1, $s1, $v0
  sub     $s2, $s2, $v0
  j       encode_rle_main_loop

encode_rle_main_finish:
  beqz    $s2, encode_rle_buffer_complete

# write a null terminator at the end of the encoding
  sb      $zero, 0($s1)
# calculate size of written bytes and then exit
  sub     $v0, $s1, $a1
  li      $v1, 0
  j       encode_rle_exit

encode_rle_buffer_complete:
  li      $v1, 2
  j       encode_rle_exit

encode_rle_invalid:
  li      $v1, 1
  j       encode_rle_exit

encode_rle_exit:
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
  jr      $ra
### encode_rle end

### decode_rle start
# args:
#       $a0: original string address
#       $a1: decoded buffer address 
#       $a2: decoded buffer capacity
# returns: 
#       $v0: decoded length including null terminator
#       $v1: 0 on success; 1 for malformed encoded string; 2 for decoded buffer overflow
decode_rle:
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

# How many bytes have we written to the output buffer
  li      $s5, 0

decode_rle_loop:
# While the current byte is not the null terminator, go into the loop
  lb      $s3, 0($s0)
  beqz    $s3, decode_rle_loop_finish

# This character should be an uppercase character and nothing else
  blt     $s3, 0x41, decode_rle_malformed
  bgt     $s3, 0x5A, decode_rle_malformed

# We read the uppercase character so move the pointer ahead by 1
  addi    $s0, $s0, 1

# Read the value of count now next in the buffer
  move    $a0, $s0
  jal     atou

# If the read failed or the value was zero, then the input was malformed
  bnez    $v1, decode_rle_malformed
  beqz    $v0, decode_rle_malformed

  move    $s4, $v0

# Incrementing the bytes we read from the input pointer
  addi    $s0, $s0, $s4

# Store the character in the output buffer count times
decode_rle_sub_loop:
  beqz    $s4, decode_rle_sub_loop_finish
  beqz    $s2, decode_rle_overflow

# Store the character in the output buffer
  sb      $s3, 0($s1)

# Increment the pointers and write count
# and decrement the count and buffer capacity
  addi    $s4, $s4, -1
  addi    $s2, $s2, -1
  addi    $s1, $s1, 1
  addi    $s5, $s5, 1
  j       decode_rle_sub_loop

decode_rle_sub_loop_finish:
# We already incremented the input pointer by the amount of count
# so go back to decoding an upper-case character
  j       decode_rle_loop

decode_rle_loop_finish:
# No space for the null terminator
  beqz    $s2, decode_rle_overflow

# Null terminating the output buffer
  sb      $zero, 0($s1)

# Store the written bytes and success code to the return registers
  move    $v0, $s5
  li      $v1, 0
  j       decode_rle_exit

decode_rle_malformed:
  li      $v1, 1
  j       decode_rle_exit

decode_rle_overflow:
  li      $v1, 2
  j       decode_rle_exit

decode_rle_exit:
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
  jr      $ra
### decode_rle end

### compare_strings start
#       $a0: first string address
#       $a1: second string address 
# returns: 
#       $v0: 1 on equal, 0 otherwise
compare_strings:
  move    $t0, $a0
  move    $t1, $a1

compare_strings_loop:
# Load the first bytes of both strings
  lb      $t2, 0($t0)
  lb      $t3, 0($t1)

# If the bytes don't match then the strings are unequal
  bne     $t2, $t3, compare_strings_unequal
  nop 

# If the bytes were equal and equal to null terminator, then strings were equal
  beqz    $t2, compare_strings_equal
  nop

# Otherwise increment the pointer by 1 and compare the first bytes agains
  addi    $t0, $t0, 1
  addi    $t1, $t1, 1
  j       compare_strings_loop

compare_strings_unequal:
  li      $v0, 0
  j       compare_strings_exit

compare_strings_equal:
  li      $v0, 1
  j       compare_strings_exit

compare_strings_exit:
  jr      $ra
### compare_strings end

### utoa start
# args: 
#       $a0: base address of the output buffer
#       $a1: size of the output buffer
#       $a2: unsigned integer to be written
# returns: 
#       $v0: length of bytes written (doesn't write null terminator)
#       $v1: 0 on success; 1 on failure
utoa: 
  move    $t0, $a0
  move    $t1, $a1
  move    $t2, $a2

# If the buffer is empty, then we can't write bytes
  beqz    $t1, utoa_buffer_complete
  nop

# If the initial number was zero then just write a zero and return
  bnez    $t2, utoa_uint_zero
  nop

utoa_loop_setup:
# Setup the length of the written buffer and the divisor (10)
  li      $t3, 0
  li      $t4, 10

utoa_loop:
# The number is now 0 so we finish the writing
  beqz    $t2, utoa_reverse
  nop

# The buffer is complete and we can't write more bytes
  beqz    $t1, utoa_buffer_complete
  nop

# Get the quotient and remainder
  div     $t2, $t4
  mflo    $t2
  mfhi    $t5

# get the ascii value of the remainder and write it to the buffer
  ori     $t5, $t5, 0x30
  sb      $t5, 0($t0)

# increment the buffer pointer, decrement remaining size and increment size written
  addi    $t0, $t0, 1
  addi    $t1, $t1, -1
  addi    $t3, $t3, 1

# Go back to converting
  j       utoa_loop

# Since we wrote the digits in reverse order, we need to reverse the buffer
utoa_reverse:
# getting the starting and ending pointers
  move    $t6, $a0
  move    $t7, $t0
  addi    $t7, $t7, -1

utoa_reverse_loop:
# if the start pointer is greater than or equal to the ending pointer then finish
  bge     $t6, $t7, utoa_finish
  lb      $t8, 0($t6)
  lb      $t9, 0($t7)

# swap the bytes stored at starting and ending pointer
  sb      $t9, 0($t6)
  sb      $t8, 0($t7)

# Increment the starting pointer and decrement the ending pointer
  addi    $t6, $t6, 1
  addi    $t7, $t7, -1
  j       utoa_reverse_loop

utoa_finish:
  move    $v0, $t3

  j       utoa_exit

# Writing a zero to the buffer incase input was zero
utoa_uint_zero:
  li      $t3, 0x30
  sb      $t3, 0($t0)

  li      $v0, 1
  li      $v1, 0
  j       utoa_exit

# The buffer capacity wasn't sufficient
utoa_buffer_complete:
  li      $v0, 0
  li      $v1, 1
  j       utoa_exit

utoa_exit:
  jr      $ra
### utoa end

### atou start
# args: 
#       $a0: base address of the input buffer
# returns: 
#       $v0: length of bytes read which were digits (doesn't write null terminator)
#       $v1: 0 on success; 1 on failure
atou:
  move    $t0, $a0

# Storing the first byte of the string to parse
  lb      $t3, 0($t0)

  blt     $t3, 0x30, atou_no_number
  nop 

  bgt     $t3, 0x39, atou_no_number
  nop

# Initializing the starting value, the multiplier, and read bytes
  li      $t4, 0
  li      $t5, 10
  li      $t7, 0

atou_loop:
  lb      $t3, 0($t0)

  blt     $t3, 0x30, atou_loop_finish
  nop

  bgt     $t3, 0x39, atou_loop_finish
  nop

  andi    $t6, $t3, 0xF
  mul     $t4, $t4, $t5
  add     $t4, $t4, $t6

  addi    $t0, $t0, 1
  addi    $t7, $t7, 1

  j       atou_loop

atou_loop_finish:
# Setting up the return registers
  move    $v0, $t4
  move    $v1, $t7
  j       atou_exit

atou_no_number:
  li      $v1, 1
  j       atou_exit

atou_exit:
  jr      $ra
### atou end

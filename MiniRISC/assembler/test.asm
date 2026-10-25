; =========================================================================
; test.asm - Sample program from opcode_allocation.md
; =========================================================================

.data
counter:
    .word 5
start_data:
    .word 20, 30, 40, 50

.text
    add  r1, r0, r0
    addi r3, r0, start_data
    addi r5, r0, 20
    addi r7, r0, counter
    lw   r2, 0(r7)
loop:
    lw   r4, 0(r3)
    add  r6, r4, r5
    xor  r6, r6, r5
    sw   r6, 4(r3)
    addi r3, r3, 4
    decj r2, loop
    nop
    halt

; =========================================================================
; test_align.asm - Testing .byte, .align=x, and .word
; =========================================================================

.data
flag1:
    .byte 0x11
flag2:
    .byte 0x22
.align=2            ; Align to next (1 << 2) = 4-byte boundary
val_word:
    .word 0x12345678
val_byte:
    .byte 0xAA
.align=4            ; Align to next (1 << 4) = 16-byte boundary
vec_data:
    .word 1, 2, 3, 4

.text
    lw   r1, val_word(r0)
    lb   r2, flag1(r0)
    lb   r3, flag2(r0)
    lb   r4, val_byte(r0)
    halt

#!/usr/bin/env python3
"""
Comprehensive test suite for Mini RISC Assembler.
"""

import os
import sys
from assembler import Assembler, SCALAR_REGISTERS, VECTOR_REGISTERS

def test_opcode_allocation_example():
    print("Testing opcode_allocation.md example...")
    asm = Assembler("test.asm")
    assembled = asm.assemble()

    expected_hex = [
        "16001000",  # [0]  add  r1, r0, r0
        "62030004",  # [1]  addi r3, r0, start_data (0x0004)
        "62050014",  # [2]  addi r5, r0, 20         (0x0014)
        "62070000",  # [3]  addi r7, r0, counter    (0x0000)
        "75720000",  # [4]  lw   r2, 0(r7)
        "75340000",  # [5]  lw   r4, 0(r3)
        "16456000",  # [6]  add  r6, r4, r5
        "17656010",  # [7]  xor  r6, r6, r5
        "71360004",  # [8]  sw   r6, 4(r3)
        "62330004",  # [9]  addi r3, r3, 4
        "6E20FFFA",  # [10] decj r2, loop           (imm = -6 -> 0xFFFA)
        "C0000000",  # [11] nop
        "E0000000",  # [12] halt
    ]

    assert len(assembled) == len(expected_hex), f"Expected {len(expected_hex)} instructions, got {len(assembled)}"

    for i, (inst, exp) in enumerate(zip(assembled, expected_hex)):
        assert inst["hex"] == exp, f"Instruction [{i}] mismatch: got {inst['hex']}, expected {exp}"

    # Check data symbols
    assert asm.data_symbols["counter"] == 0x0000, f"counter symbol: {asm.data_symbols['counter']}"
    assert asm.data_symbols["start_data"] == 0x0004, f"start_data symbol: {asm.data_symbols['start_data']}"
    print("  -> Passed opcode_allocation.md example test!")


def test_align_directive():
    print("Testing .align=x directive...")
    asm = Assembler("test_align.asm")
    asm.assemble()

    # flag1: offset 0 (1 byte) -> len 1
    # flag2: offset 1 (1 byte) -> len 2
    # .align=2 -> aligns to 1 << 2 = 4 -> len 4
    # val_word: offset 4 (4 bytes) -> len 8
    # val_byte: offset 8 (1 byte) -> len 9
    # .align=4 -> aligns to 1 << 4 = 16 -> len 16
    # vec_data: offset 16 (16 bytes) -> len 32

    assert asm.data_symbols["flag1"] == 0, f"flag1 offset: {asm.data_symbols['flag1']}"
    assert asm.data_symbols["flag2"] == 1, f"flag2 offset: {asm.data_symbols['flag2']}"
    assert asm.data_symbols["val_word"] == 4, f"val_word offset: {asm.data_symbols['val_word']}"
    assert asm.data_symbols["val_byte"] == 8, f"val_byte offset: {asm.data_symbols['val_byte']}"
    assert asm.data_symbols["vec_data"] == 16, f"vec_data offset: {asm.data_symbols['vec_data']}"
    assert len(asm.data_bytes) == 32, f"Total data bytes: {len(asm.data_bytes)}"

    # Check byte padding
    # bytes 2, 3 should be 0
    assert asm.data_bytes[2] == 0 and asm.data_bytes[3] == 0
    # bytes 9..15 should be 0
    for b in range(9, 16):
        assert asm.data_bytes[b] == 0, f"Byte at {b} not zero: {asm.data_bytes[b]}"

    print("  -> Passed .align=x directive test!")


def test_all_isa_instructions():
    print("Testing all ISA instruction encodings...")
    test_asm_content = """
.text
    ; R-type ALU
    add  r1, r2, r3
    sub  r4, r5, r6
    and  r7, r8, r9
    or   r10, r11, r12
    xor  r13, r14, r15
    nor  r1, r2, r3
    not  r4, r5
    sll  r6, r7, 5
    srl  r8, r9, 3
    sra  r10, r11, 2
    sllv r1, r2, r3
    srlv r4, r5, r6
    srav r7, r8, r9
    cmp  r1, r2
    mul  r3, r4, r5
    jr   r15
    cmovz r1, r2
    cmovn r3, r4
    cmovg r5, r6
    cmovl r7, r8

    ; Vector R-type
    addv v1, v2, v3
    subv v4, v5, v6
    andv v7, v8, v9
    orv  v10, v11, v12
    xorv v13, v14, v15
    norv v1, v2, v3
    splat v1, r2
    reds r1, v2
    reda r3, v4
    redo r5, v6
    redx r7, v8
    redn r9, v10

    ; I-type
    splati v1, 42
    addi r1, r2, 100
    andi r3, r4, 0x0F
    ori  r5, r6, 0xF0
    xori r7, r8, 0xAA
    nori r9, r10, 0x55
    lui  r1, 0x1234
target_decj:
    decj r1, target_decj
    lb   r1, 4(r2)
    sb   r3, 8(r4)
    lw   r5, 12(r6)
    sw   r7, 16(r8)
    lv   v1, 32(r2)
    sv   v2, 48(r3)
    lbi  r1, 1(r2)
    sbi  r3, 2(r4)
    lwi  r5, 4(r6)
    swi  r7, 8(r8)

    ; J-type
target_jump:
    j    target_jump
    jal  target_jump
    bz   target_jump
    bn   target_jump
    bg   target_jump
    bl   target_jump

    ; Special
    nop
    halt
"""
    tmp_path = "_tmp_test_all.asm"
    with open(tmp_path, "w") as f:
        f.write(test_asm_content)

    asm = Assembler(tmp_path)
    assembled = asm.assemble()
    os.remove(tmp_path)

    # Validate specific instructions
    # add r1, r2, r3: opcode=0x16, rs=2, rt=3, rd=1, funct=0x00 -> 0x16231000
    assert assembled[0]["hex"] == "16231000", f"add: {assembled[0]['hex']}"

    # sub r4, r5, r6: opcode=0x16, rs=5, rt=6, rd=4, funct=0x40 -> 0x16564040
    assert assembled[1]["hex"] == "16564040", f"sub: {assembled[1]['hex']}"

    # not r4, r5: opcode=0x17, rs=5, rt=0, rd=4, funct=0x20 -> 0x17504020
    assert assembled[6]["hex"] == "17504020", f"not: {assembled[6]['hex']}"

    # sll r6, r7, 5: opcode=0x15, rs=7, rt=0, rd=6, shamt=5 (5<<7=0x280), funct=0x01 -> 0x15706281
    assert assembled[7]["hex"] == "15706281", f"sll: {assembled[7]['hex']}"

    # cmp r1, r2: opcode=0x12, rs=1, rt=2, rd=0, funct=0x40 -> 0x12120040
    assert assembled[13]["hex"] == "12120040", f"cmp: {assembled[13]['hex']}"

    # jr r15: opcode=0x20, rs=15, rt=0, rd=0, funct=0x08 -> 0x20F00008
    assert assembled[15]["hex"] == "20F00008", f"jr: {assembled[15]['hex']}"

    # cmovz r1, r2: opcode=0x08, rs=2, rt=0, rd=1, funct=0x40 -> 0x08201040
    assert assembled[16]["hex"] == "08201040", f"cmovz: {assembled[16]['hex']}"

    # addv v1, v2, v3: opcode=0x02, vs=2, vt=3, vd=1, funct=0x00 -> 0x02231000
    assert assembled[20]["hex"] == "02231000", f"addv: {assembled[20]['hex']}"

    # splat v1, r2: opcode=0x00, rs=2, vt=0, vd=1, funct=0x08 -> 0x00201008
    assert assembled[26]["hex"] == "00201008", f"splat: {assembled[26]['hex']}"

    # reds r1, v2: opcode=0x06, vs=2, vt=0, rd=1, funct=0x00 -> 0x06201000
    assert assembled[27]["hex"] == "06201000", f"reds: {assembled[27]['hex']}"

    # splati v1, 42: opcode=0x40, rs=0, rt=1, imm=42 (0x002A) -> 0x4001002A
    assert assembled[32]["hex"] == "4001002A", f"splati: {assembled[32]['hex']}"

    # lui r1, 0x1234: opcode=0x60, rs=0, rt=1, imm=0x1234 -> 0x60011234
    assert assembled[38]["hex"] == "60011234", f"lui: {assembled[38]['hex']}"

    # decj r1, target_decj: target=39, current=39 -> offset = 39 - (39 + 1) = -1 = 0xFFFF
    # opcode=0x6E, rs=1, rt=0, imm=0xFFFF -> 0x6E10FFFF
    assert assembled[39]["hex"] == "6E10FFFF", f"decj: {assembled[39]['hex']}"

    # lv v1, 32(r2): opcode=0x76, rs=2, vt=1, imm=32 (0x0020) -> 0x76210020
    assert assembled[44]["hex"] == "76210020", f"lv: {assembled[44]['hex']}"

    # lwi r5, 4(r6): opcode=0x7D, rs=6, rt=5, imm=4 (0x0004) -> 0x7D650004
    assert assembled[48]["hex"] == "7D650004", f"lwi: {assembled[48]['hex']}"

    # j target_jump: idx=50, target=50 -> jta = 50 = 0x000032
    # opcode=0x81 -> 0x81000032
    assert assembled[50]["hex"] == "81000032", f"j: {assembled[50]['hex']}"

    # bz target_jump: idx=52, target=50 -> offset = 50 - (52 + 1) = -3 = 0xFFFD
    # opcode=0xA0, imm=0xFFFD -> 0xA000FFFD
    assert assembled[52]["hex"] == "A000FFFD", f"bz: {assembled[52]['hex']}"

    # nop -> 0xC0000000
    assert assembled[56]["hex"] == "C0000000", f"nop: {assembled[56]['hex']}"

    # halt -> 0xE0000000
    assert assembled[57]["hex"] == "E0000000", f"halt: {assembled[57]['hex']}"

    print("  -> Passed all ISA instruction encodings test!")


def test_coe_output_generation():
    print("Testing COE output generation...")
    asm = Assembler("test.asm")
    assembled = asm.assemble()

    inst_coe = asm.generate_instruction_coe(assembled)
    data_coe = asm.generate_data_coe()

    # Verify instruction COE format
    assert "; Mini RISC Instruction Memory Initialization (instruction.coe)" in inst_coe
    assert "memory_initialization_radix = 16;" in inst_coe
    assert "memory_initialization_vector =" in inst_coe
    assert "16001000," in inst_coe
    assert "E0000000;" in inst_coe

    # Verify data COE format
    assert "; Mini RISC Data Memory Initialization (data.coe)" in data_coe
    assert "Port A Width: 128-bit" in data_coe
    assert "Port B Width: 32-bit" in data_coe
    assert "memory_initialization_radix = 16;" in data_coe
    assert "memory_initialization_vector =" in data_coe

    # In test.asm:
    # counter: .word 5 (Word0 = 5)
    # start_data: .word 20, 30, 40, 50 (Word1 = 20=0x14, Word2 = 30=0x1E, Word3 = 40=0x28, Word4 = 50=0x32)
    # Line 0: Word3_Word2_Word1_Word0 = 000000280000001E0000001400000005
    # Line 1: Word7_Word6_Word5_Word4 = 00000000000000000000000000000032
    assert "000000280000001E0000001400000005," in data_coe
    assert "00000000000000000000000000000032;" in data_coe

    print("  -> Passed COE output generation test!")


def test_multiplier_instructions():
    print("Testing MUL, MAC, MULV, MACV instruction encodings...")
    content = """
.text
    mul  r3, r4, r5
    mac  r1, r2, r3
    mulv v1, v2, v3
    macv v4, v5, v6
"""
    tmp_path = "_tmp_test_mult.asm"
    with open(tmp_path, "w") as f:
        f.write(content)

    asm = Assembler(tmp_path)
    assembled = asm.assemble()
    os.remove(tmp_path)

    assert len(assembled) == 4
    # mul: opcode=0x28, rs=4, rt=5, rd=3, funct=0x00 -> 0x28453000
    assert assembled[0]["hex"] == "28453000", f"mul: {assembled[0]['hex']}"
    # mac: opcode=0x29, rs=2, rt=3, rd=1, funct=0x00 -> 0x29231000
    assert assembled[1]["hex"] == "29231000", f"mac: {assembled[1]['hex']}"
    # mulv: opcode=0x2C, vs=2, vt=3, vd=1, funct=0x00 -> 0x2C231000
    assert assembled[2]["hex"] == "2C231000", f"mulv: {assembled[2]['hex']}"
    # macv: opcode=0x2D, vs=5, vt=6, vd=4, funct=0x00 -> 0x2D564000
    assert assembled[3]["hex"] == "2D564000", f"macv: {assembled[3]['hex']}"

    # Test error handling
    for bad_asm in [
        "mac v1, r2, r3",   # mac with vector dest
        "mac r1, v2, r3",   # mac with vector src
        "mulv r1, v2, v3",  # mulv with scalar dest
        "macv v1, r2, v3",  # macv with scalar src
        "mac r1, r2",       # missing operand
        "mulv v1, v2",      # missing operand
        "macv v1, v2, v3, v4", # too many operands
    ]:
        with open(tmp_path, "w") as f:
            f.write(f".text\n{bad_asm}\n")
        asm = Assembler(tmp_path)
        try:
            asm.assemble()
            assert False, f"Expected error for '{bad_asm}', but passed"
        except ValueError:
            pass
        finally:
            if os.path.exists(tmp_path):
                os.remove(tmp_path)

    print("  -> Passed MUL, MAC, MULV, MACV instruction encodings test!")


if __name__ == "__main__":
    test_opcode_allocation_example()
    test_align_directive()
    test_all_isa_instructions()
    test_multiplier_instructions()
    test_coe_output_generation()
    print("\nALL TESTS PASSED SUCCESSFULLY! 100% verified.")

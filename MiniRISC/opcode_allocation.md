R type: 0x00
I type: 0x01
J type: 0x10
NOP/HALT: 0x11

# R type: 
6 bits remaining opcode; 7 bits funct
* ADD, SUB, AND, OR, XOR, NOR, NOT, SLL, SRL, SRA, SLLV, SRLV, SRAV, CMP, 
* MUL,
* CMOVZ, CMOVN, CMOVG, CMOVL, 
* JR, 
* ADDV, SUBV, ANDV, ORV, XORV, NORV, SPLAT,
* REDS, REDA, REDO, REDX, REDN,

* MAC, MULV, MACV *NOT ALLOCATED CURRENTLY*

opcode: 8 bits
opcode[7:6] = 0b00
opcode[5:3] = src of write back MUX:
            * 0b000 => Vector instruction
            * 0b001 => Conditional move type instruction
            * 0b010 => ALU type instruction
            * 0b011 => Data memory instruction
            * 0b100 => PC type instruction
            * 0b101 => MUL instruction
            * 0b110 => currently unallocated
            * 0b111 => currently unallocated

## Vector instruction
opcode[2]   = reduction 
        
### Vector -> Vector instruction
opcode[1:0] = func_class
funct[6]    = add_bar_sub
funct[5:4]  = logic_func
funct[3]    = splat_src
* ADDV      : 0b00 000 0 10 (vs, vt, vd) 0 00 0 000
* SUBV      : 0b00 000 0 10 (vs, vt, vd) 1 00 0 000 
* ANDV      : 0b00 000 0 11 (vs, vt, vd) 0 00 0 000
* ORV       : 0b00 000 0 11 (vs, vt, vd) 0 01 0 000
* XORV      : 0b00 000 0 11 (vs, vt, vd) 0 10 0 000
* NORV      : 0b00 000 0 11 (vs, vt, vd) 0 11 0 000
* SPLAT     : 0b00 000 0 00 (vs, vt, vd) 0 00 1 000

### Vector -> Scalar instruction
opcode[1:0] = func_class
funct[6]    = add_bar_sub
funct[5:4]  = logic_func
funct[3]    = splat_src
* REDS      : 0b00 000 1 10 (vs, vt, rd) 0 00 0 000
* REDA      : 0b00 000 1 11 (vs, vt, rd) 0 00 0 000
* REDO      : 0b00 000 1 11 (vs, vt, rd) 0 01 0 000
* REDX      : 0b00 000 1 11 (vs, vt, rd) 0 10 0 000
* REDN      : 0b00 000 1 11 (vs, vt, rd) 0 11 0 000


## Conditional Move type instruction
funct[6]    = zero
funct[5]    = non_zero
funct[4]    = greater
funct[3]    = lesser_equal
* CMOVZ     : 0b00 001 000 (rs, rt, rd) 1 0 0 0 000
* CMOVN     : 0b00 001 000 (rs, rt, rd) 0 1 0 0 000
* CMOVG     : 0b00 001 000 (rs, rt, rd) 0 0 1 0 000
* CMOVL     : 0b00 001 000 (rs, rt, rd) 0 0 0 1 000


## For ALU type instruction
opcode[2]   = reg_write
opcode[1:0] = func_class
funct[6]    = add_bar_sub
funct[5:3]  = logic_func
funct[2]    = shift_src
funct[1:0]  = shift_func

* ADD       : 0b00 010 1 10 (rs, rt, rd) 0 000 0 00
* SUB       : 0b00 010 1 10 (rs, rt, rd) 1 000 0 00
* AND       : 0b00 010 1 11 (rs, rt, rd) 0 000 0 00
* OR        : 0b00 010 1 11 (rs, rt, rd) 0 001 0 00
* XOR       : 0b00 010 1 11 (rs, rt, rd) 0 010 0 00
* NOR       : 0b00 010 1 11 (rs, rt, rd) 0 011 0 00
* NOT       : 0b00 010 1 11 (rs, rt, rd) 0 100 0 00
* SLL       : 0b00 010 1 01 (rs, rt, rd) 0 000 0 01
* SRL       : 0b00 010 1 01 (rs, rt, rd) 0 000 0 10
* SRA       : 0b00 010 1 01 (rs, rt, rd) 0 000 0 11
* SLLV      : 0b00 010 1 01 (rs, rt, rd) 0 000 1 01
* SRLV      : 0b00 010 1 01 (rs, rt, rd) 0 000 1 10
* SRAV      : 0b00 010 1 01 (rs, rt, rd) 0 000 1 11
* CMP       : 0b00 010 0 10 (rs, rt, rd) 1 000 0 00

## PC type instruction
funct[6]    = branch
funct[5:4]  = br_type
funct[3:2]  = pc_src
* JR        : 0b00 100 000 (rs, rt, rd) 0 00 10 00

## MUL instruction
* MUL       : 0b00 101 000 (rs, rt, rd) 0000000

# I type:
6 bits opcode remaining
* SPLATI,
* ADDI, ANDI, ORI, XORI, NORI, LUI, DECJ,
* LB, SB, LW, SW, LV, SV, LBI, SBI, LWI, SWI,

opcode: 8bits
opcode[7:6] = 0b01
opcode[5:4] : last two bits of write back used
            * 0b00 => vector instruction
            * 0b10 => ALU instruction
            * 0b11 => Data type instruction

## Vector instruction
opcode[2]   = splat_src
opcode[1:0] = func_class
* SPLATI    : 0b01 00 0000 (rs, rt) imm

## ALU instructions
(opcode[3] 
& opcode[2])= add_bar_sub
opcode[3:2] = logic_func
opcode[1:0] = func_class
* ADDI      : 0b01 10 0010 (rs, rt) imm
* ANDI      : 0b01 10 0011 (rs, rt) imm
* ORI       : 0b01 10 0111 (rs, rt) imm
* XORI      : 0b01 10 1011 (rs, rt) imm
* NORI      : 0b01 10 1111 (rs, rt) imm
* LUI       : 0b01 10 0000 (rs, rt) imm
* DECJ      : 0b01 10 1110 (rs, rt) imm

## Data type instructions
opcode[3]   = whether to increment
opcode[2]   = store_bar_load
opcode[1:0] = type of load/store
            * 0b00 => byte
            * 0b01 => word
            * 0b10 => vector

* LB        : 0b01 11 0 1 00 (rs, rt) imm
* SB        : 0b01 11 0 0 00 (rs, rt) imm
* LW        : 0b01 11 0 1 01 (rs, rt) imm
* SW        : 0b01 11 0 0 01 (rs, rt) imm
* LV        : 0b01 11 0 1 10 (rs, rt) imm
* SV        : 0b01 11 0 0 10 (rs, rt) imm
* LBI       : 0b01 11 1 1 00 (rs, rt) imm
* SBI       : 0b01 11 1 0 00 (rs, rt) imm
* LWI       : 0b01 11 1 1 01 (rs, rt) imm
* SWI       : 0b01 11 1 0 01 (rs, rt) imm

# J type:
6 opcode bits remaining
* J, JAL, 
* BZ, BN, BG, BL,

opcode[7:6] = 0b10
opcode[5]   = unconditional_bar_conditional
opcode[4]   = branch
opcode[3:2] = br_type
opcode[1:0] = pc_src

* J         : 0b10 0 0 00 01 jta
* JAL       : 0b10 0 1 00 01 jta
* BZ        : 0b10 1 0 00 00 00000000 imm
* BN        : 0b10 1 0 01 00 00000000 imm
* BG        : 0b10 1 0 10 00 00000000 imm
* BL        : 0b10 1 0 11 00 00000000 imm

# NOP/HALT:
* NOP       : 0b110 (29 0)
* HALT      : 0b111 (29 0)

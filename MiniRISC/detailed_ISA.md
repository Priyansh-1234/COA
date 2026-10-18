# ISA
## ISA with SIMD: (61 instructions)
### ALU: (26 instructions)
* Arithemetic: (3 instructions) 
    * ADD       (rd <- rs + rt)
    * SUB       (rd <- rs - rt)
    * ADDI      (rt <- rs + imm)
* Logical: (9 instructions)
    * AND       (rd <- rs & rt)
    * OR        (rd <- rs | rt)
    * XOR       (rd <- rs ^ rt)
    * NOR       (rd <- ~(rs | rt))
    * ANDI      (rd <- rs & imm)
    * ORI       (rd <- rs & imm)
    * XORI      (rd <- rs & imm)
    * NORI      (rd <- rs & imm)
    * NOT       (rd <- ~rs)
* Shift: (6 instructions)
    * SLL       (rd <- rs << shamt)
    * SRL       (rd <- rs >> shamt)
    * SRA       (rd <- rs >> shamt with sign extenstion)
    * SLLV      (rd <- rs << rt)
    * SRLV      (rd <- rs >> rt)
    * SRAV      (rd <- rs >> rt with sign extenstion)
* Multiplier: (2 instructions)
    * MUL       (rd <- rs * rt)
    * MAC       (rd <- rd + rs * rt)
* Compare: (1 instruction)
    * CMP       (rs - rt sets up the flags)
* Moves: (5 instruction)
    * LUI       (rt <- imm << necessary bits)
    * CMOVZ     (rd <- rs if zero flag set)
    * CMOVN     (rd <- rs if zero flag not set)
    * CMOVG     (rd <- rs if zero flag not set and sign flag not set)
    * CMOVL     (rd <- rs if zero flag not set and sign flag set)
### Memory: (10 instructions)
* Load Store:
    * LB        (rt <- imm(rs) byte)
    * LW        (rt <- imm(rs) word)
    * LV        (rt <- imm(rs) vector)
    * SB        (imm(rs) <- rt byte)
    * SW        (imm(rs) <- rt word)
    * SV        (imm(rs) <- rt vector)
    * LBI       (rt <- imm(rs) byte; rs <- rs + 1)
    * LWI       (rt <- imm(rs) word; rs <- rs + 4)
    * SBI       (imm(rs) <- rt byte; rs <- rs + 1)
    * SWI       (imm(rs) <- rt word; rs <- rs + 4)
### Branch: (8 instructions)
* Unconditional Jump: (3 instructions)
    * J         (PC <- PC | offset)
    * JR        (PC <- rs)
    * JAL       (PC <- PC | offset; ra <- PC)
* Conditional Jump: (5 instructions)
    * BZ        (PC <- PC + imm if zero flag set)       
    * BN        (PC <- PC + imm if zero flag not set)
    * BG        (PC <- PC + imm if zero flag not set and sign flag not set)
    * BL        (PC <- PC + imm if zero flag not set and sign flag set)
    * DJ        (rt <- rt - 1   if zero flag not set then jump; PC <- PC + imm)
### Program Control: (2 instructions)
* NOP       (Does nothing)
* HALT      (Stops the execution)
### SIMD: (15 instructions)
* Data Load: (2 instructions)
    * SPLAT     (all 4 32bit parts of the vector register <- rs)
    * SPLATI    (all 4 32bit parts of the vector register <- imm)
* ALU: (6 - 8 instructions)
    * ADDV      (vd <- vs + vt;     4 operations in parallel)
    * SUBV      (vd <- vs - vt;     4 operations in parallel)
    * ANDV      (vd <- vs & vt;     4 operations in parallel)
    * ORV       (vd <- vs | vt;     4 operations in parallel)
    * XORV      (vd <- vs ^ vt;     4 operations in parallel)
    * NORV      (vd <- ~(vs | vt);  4 operations in parallel)
    * MULV      (vd <- vs * vt;     4 operations in parallel)
    * MACV      (vd <- vd + vs * vt;4 operations in parallel)
    *Note: We might not include the last 2/3 instructions here*
* Reductions: (5 instructions)
    * REDS      (rd <- +(vs);       reduction of vector with sum)
    * REDA      (rd <- &(vs);       reduction of vector with and)
    * REDO      (rd <- |(vs);       reduction of vector with or)
    * REDX      (rd <- ^(vs);       reduction of vector with xor)
    * REDN      (rd <- ~|(vs);      reduction of vector with nor)

## ISA without SIMD: (44 instructions)
### ALU: (26 instructions)
* Arithemetic: (3 instructions)
    * ADD       (rd <- rs + rt)
    * SUB       (rd <- rs - rt)
    * ADDI      (rt <- rs + imm)
* Logical: (9 instructions)
    * AND       (rd <- rs & rt)
    * OR        (rd <- rs | rt)
    * XOR       (rd <- rs ^ rt)
    * NOR       (rd <- ~(rs | rt))
    * ANDI      (rd <- rs & imm)
    * ORI       (rd <- rs & imm)
    * XORI      (rd <- rs & imm)
    * NORI      (rd <- rs & imm)
    * NOT       (rd <- ~rs)
* Shift: (6 instructions)
    * SLL       (rd <- rs << shamt)
    * SRL       (rd <- rs >> shamt)
    * SRA       (rd <- rs >> shamt with sign extenstion)
    * SLLV      (rd <- rs << rt)
    * SRLV      (rd <- rs >> rt)
    * SRAV      (rd <- rs >> rt with sign extenstion)
* Multiplier: (2 instructions)
    * MUL       (rd <- rs * rt)
    * MAC       (rd <- rd + rs * rt)
* Compare: (1 instruction)
    * CMP       (rs - rt sets up the flags)
* Moves: (5 instructions)
    * LUI       (rt <- imm << necessary bits)
    * CMOVZ     (rd <- rs if zero flag set)
    * CMOVN     (rd <- rs if zero flag not set)
    * CMOVG     (rd <- rs if zero flag not set and sign flag not set)
    * CMOVL     (rd <- rs if zero flag not set and sign flag set)
### Memory: (8 instructions)
* Load Store: (8 instructions)
    * LB        (rt <- imm(rs) byte)
    * LW        (rt <- imm(rs) word)
    * SB        (imm(rs) <- rt byte)
    * SW        (imm(rs) <- rt word)
    * LBI       (rt <- imm(rs) byte; rs <- rs + 1)
    * LWI       (rt <- imm(rs) word; rs <- rs + 4)
    * SBI        (imm(rs) <- rt byte; rs <- rs + 1)
    * SWI        (imm(rs) <- rt word; rs <- rs + 4)
### Branch/Jump : (8 instructions)
* Unconditional Jump: (3 instructions)
    * J         (PC <- PC | offset)
    * JR        (PC <- rs)
    * JAL       (PC <- PC | offset; ra <- PC)
* Conditional Jump: (5 instructions)
    * BZ        (PC <- PC + imm if zero flag set)       
    * BN        (PC <- PC + imm if zero flag not set)
    * BG        (PC <- PC + imm if zero flag not set and sign flag not set)
    * BL        (PC <- PC + imm if zero flag not set and sign flag set)
    * DJ        (rt <- rt - 1   if zero flag not set then jump; PC <- PC + imm)
### Program Control: (2 instructions)
* NOP       (Does nothing)
* HALT      (Stops the execution)


# Registers
* PC (Program Counter)
* IR (Instruction Register)
* GPRS (32 bit):
    * r0 (zero) : zero register (hard coded to always be zero)
    * r1...r11  : general purpose
    * r12 (gp)  : global pointer
    * r13 (sp)  : stack pointer
    * r14 (fp)  : frame pointer
    * r15 (ra)  : return address register
* Vector registers (128 bit):
    * v0...v3

# Instruction Encodings:
## R type Instructions [opcode : 8, rs: 4, rt: 4, rd: 4, shamt: 5, funct: 7]
* R type using only 32bit registers:
    * ADD
    * SUB
    * AND
    * OR
    * XOR
    * NOR
    * NOT
    * SLL
    * SRL
    * SRA
    * SLLV
    * SRLV
    * SRAV
    * MUL
    * MAC
    * CMP
    * CMOVZ
    * CMOVN
    * CMOVG
    * CMOVL
    * JR

* R type using only vector registers:
    * ADDV
    * SUBV
    * ANDV
    * ORV
    * XORV
    * NORV
    * MULV
    * MACV

* R type instructions using both 32bit and vector registers:
    * SPLAT
    * REDS
    * REDA
    * REDO
    * REDX
    * REDN

## I type Instructions: [opcode: 8, rs: 4, rt: 4, imm: 16]
* I type employing ALU:
    * ADDI
    * ANDI
    * ORI
    * XORI
    * NORI
    * LUI
    * LB
    * SB
    * LW
    * SW
    * LV
    * SV
    * LBI
    * SBI
    * LWI
    * SWI
    * DJ
    * SPLATI

## J type: [opcode: 8, jta: 24]
    * J
    * JAL
    * BZ
    * BN
    * BG
    * BL

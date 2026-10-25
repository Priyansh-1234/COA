# Mini RISC Assembler

An assembler for the 32-bit Mini RISC Harvard Architecture ISA defined in [`opcode_allocation.md`](opcode_allocation.md).

It generates Vivado-compatible `.coe` files:
- **`instruction.coe`**: 32-bit width Single Port ROM for instructions, with detailed instruction mapping headers.
- **`data.coe`**: 128-bit width Port A True Dual Port RAM (4 x 32-bit words per line, little-endian: `Word3_Word2_Word1_Word0`), word-addressed at Port B (byte-addressed by processor via `EA >> 2`).

---

## Usage

```bash
# Basic usage (outputs instruction.coe and data.coe in the current directory)
python3 assembler.py input.asm

# Specify output directory
python3 assembler.py input.asm -o ./output

# Specify custom filenames
python3 assembler.py input.asm --inst-coe my_inst.coe --data-coe my_data.coe

# Optional memory depth padding
python3 assembler.py input.asm --pad-inst 1024 --pad-data 256
```

---

## Directives Supported

### Section Directives
- `.data`: Switches to data memory segment.
- `.text`: Switches to instruction memory segment.

### Data Allocation Directives
- `.byte val1, val2, ...`: 8-bit bytes (supports integers, hex `0x..`, char literals `'c'`).
- `.half val1, ...` / `.short val1, ...`: 16-bit integers (little-endian).
- `.word val1, val2, ...`: 32-bit integers (little-endian) or data label references.
- `.vec val0, val1, val2, val3` or `.vec 0x...`: 128-bit vector constants (16 bytes).
- `.ascii "string"`: ASCII string without null terminator.
- `.asciiz "string"`: Null-terminated ASCII string.
- `.space n` / `.zero n` / `.fill n`: Reserves `n` zero bytes.

### Alignment Directive
- **`.align=x`** (also accepts `.align x`): Aligns data memory (or text) to the next **`1 << x`** byte boundary:
  - `.align=0` : 1-byte alignment (no padding)
  - `.align=1` : 2-byte alignment (halfword)
  - `.align=2` : 4-byte alignment (word)
  - `.align=3` : 8-byte alignment (doubleword)
  - `.align=4` : 16-byte alignment (128-bit vector boundary)

Example:
```assembly
.data
status:
    .byte 0x01
.align=2            ; Pads 3 zero bytes to align to next 4-byte boundary
counter:
    .word 100
.align=4            ; Pads to 16-byte boundary for vector data
vec_const:
    .word 10, 20, 30, 40
```

---

## Instruction Set Architecture Summary

### Scalar Registers
- `r0`: Zero register (hardwired to 0)
- `r1` .. `r11`: General-purpose registers
- `r12` / `rgp` / `gp`: Global pointer
- `r13` / `rsp` / `sp`: Stack pointer
- `r14` / `rfp` / `fp`: Frame pointer
- `r15` / `rra` / `ra`: Return address register

### Vector Registers
- `v0` .. `v15` or `vr0` .. `vr15`: 128-bit vector registers

### Instruction Formats

#### 1. R-Type Instructions
- **ALU Arithmetic & Logic**:
  - `add rd, rs, rt`
  - `sub rd, rs, rt`
  - `and rd, rs, rt`
  - `or rd, rs, rt`
  - `xor rd, rs, rt`
  - `nor rd, rs, rt`
  - `not rd, rs`
  - `mul rd, rs, rt`
  - `mac rd, rs, rt`
  - `cmp rs, rt`
- **Shift Operations**:
  - Immediate shifts (5-bit shamt in bits [11:7]):
    `sll rd, rs, shamt` | `srl rd, rs, shamt` | `sra rd, rs, shamt`
  - Variable shifts (register shift amount):
    `sllv rd, rs, rt` | `srlv rd, rs, rt` | `srav rd, rs, rt`
- **Conditional Moves** (evaluated on flags set by `cmp`):
  - `cmovz rd, rs` : Move if Zero
  - `cmovn rd, rs` : Move if Non-zero
  - `cmovg rd, rs` : Move if Greater
  - `cmovl rd, rs` : Move if Lesser or Equal
- **Jump Register**:
  - `jr rs`
- **Vector Operations**:
  - Vector-Vector: `addv vd, vs, vt`, `subv vd, vs, vt`, `andv vd, vs, vt`, `orv vd, vs, vt`, `xorv vd, vs, vt`, `norv vd, vs, vt`, `mulv vd, vs, vt`, `macv vd, vs, vt`
  - Scalar Broadcast to Vector: `splat vd, rs`
  - Vector-to-Scalar Reductions: `reds rd, vs`, `reda rd, vs`, `redo rd, vs`, `redx rd, vs`, `redn rd, vs`

#### 2. I-Type Instructions
- **Immediate ALU**:
  - `addi rt, rs, imm`
  - `andi rt, rs, imm`
  - `ori rt, rs, imm`
  - `xori rt, rs, imm`
  - `nori rt, rs, imm`
  - `lui rt, imm`
- **Loop Decrement & Jump**:
  - `decj rs, label` (`imm = target - (pc + 1)`)
- **Vector Broadcast Immediate**:
  - `splati vd, imm`
- **Loads & Stores**:
  - `lb rt, offset(rs)` | `sb rt, offset(rs)`
  - `lw rt, offset(rs)` | `sw rt, offset(rs)`
  - `lv vt, offset(rs)` | `sv vt, offset(rs)`
- **Auto-Increment Loads & Stores**:
  - `lbi rt, offset(rs)` | `sbi rt, offset(rs)`
  - `lwi rt, offset(rs)` | `swi rt, offset(rs)`

#### 3. J-Type Instructions
- **Unconditional Jumps** (`jta = target[23:0]`):
  - `j target`
  - `jal target`
- **Conditional Branches** (`imm = target - (pc + 1)`):
  - `bz label` : Branch if Zero flag set
  - `bn label` : Branch if Non-zero flag set
  - `bg label` : Branch if Greater flag set
  - `bl label` : Branch if Lesser flag set

#### 4. Control Instructions
- `nop` : `0xC0000000`
- `halt`: `0xE0000000`

---

## Output Format Example

### `instruction.coe`
```
; =========================================================================
; Mini RISC Instruction Memory Initialization (instruction.coe)
; Assembled from test.asm
; Radix: Hexadecimal (32-bit instructions)
; =========================================================================
;
; Instruction Mapping:
; [0]  16001000 : add  r1, r0, r0
; [1]  62030004 : addi r3, r0, start_data         (0x0004)
; [2]  62050014 : addi r5, r0, 20         (0x0014)
; [3]  62070000 : addi r7, r0, counter         (0x0000)
; [4]  75720000 : lw   r2, 0(r7)
; [5]  75340000 : lw   r4, 0(r3)  <-- loop
; [6]  16456000 : add  r6, r4, r5
; [7]  17656010 : xor  r6, r6, r5
; [8]  71360004 : sw   r6, 4(r3)
; [9]  62330004 : addi r3, r3, 4
; [10] 6E20FFFA : decj r2, loop         (imm = -6 -> 0xFFFA)
; [11] C0000000 : nop
; [12] E0000000 : halt
; =========================================================================

memory_initialization_radix = 16;
memory_initialization_vector =
16001000,
62030004,
62050014,
62070000,
75720000,
75340000,
16456000,
17656010,
71360004,
62330004,
6E20FFFA,
C0000000,
E0000000;
```

### `data.coe`
```
; =========================================================================
; Mini RISC Data Memory Initialization (data.coe)
; Assembled from test.asm
; Port A Width: 128-bit (4 x 32-bit words per line, little-endian: Word3_Word2_Word1_Word0)
; Port B Width: 32-bit (word-addressed at Port B, byte-addressed by processor via EA >> 2)
; =========================================================================
;
; Data Mapping:
; [0x0000] counter
; [0x0004] start_data
; =========================================================================

memory_initialization_radix = 16;
memory_initialization_vector =
000000280000001E0000001400000005,
00000000000000000000000000000032;
```

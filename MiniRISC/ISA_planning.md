# Basic Programmer Visible State
* Should support atleast 16 32 bit GPRS [R0...R15]
* 1 32 bit Program Counter
* a 32 bit Data Path
* Instruction Memory for storing the program
* Data Memory for Storing operands, arrays, matrices, image data and intermediate results
* Groups May reserve 1 constant-zero register, Stack Pointer and or other special purpose registers

# Arithmetic Operations that may be included
* ADD
* SUB
* ADDI
* SUBI
* INC / DEC (Only if useful)

# Logical Operations that may be included
* AND
* OR 
* XOR 
* NOR 
* NOT

# Shift Operations
* Logical Shift Left
* Logical Shift Right
* Arithmetic Shift Right

# Comparision
* SLT
* SGT
* If the Group feels like it they may use compare and branch instructions Like
    - BEQ
    - BNE
    - BLTZ

# Memory Operations
* LOAD
* STORE
* A base-register plus immediate-offset addressing mode is recommended because it is convenient
for arrays, matrices, and image data

# Branching
* Unconditional Branching
* Branch if zero
* Branch if positive
* Branch if negative

* NOP or equivalent No operation behaviour
* HALT to stop program execution

# Register Transfer and Constant Formation
## ISA should provide convenient ways to 
* Copy One Register to Another
* Load Small Constants
* Form Larger Constants when required

# Multiplier Support for Later Assignments
## Multiplier
## Multiply and Accumulate

## Two Approaches for Multicycle Timing
* Hardware stall:
    Processor Holds PC and waits until the multiplier reports completion
* Software scheduling:
    NOPs to be inserted after MUL instructions
    * Branch if carry
    * Branch if Overflow
    *Note: The Last 2 don't seem that useful compared to the others and hence could be removed*

# Instructions Planned So far: (55 instructions currently)
* Arithemetic: (3 instructions)
    * ADD
    * SUB
    * ADDI
* Logical: (9 instructions)
    * AND 
    * OR
    * XOR 
    * NOR 
    * AND with immediate value
    * OR with immediate value
    * XOR with immediate value
    * NOR with immediate value
    * NOT
* Shift: (6 instructions)
    * Logical Shift Right               (With immediate value)
    * Logical Shift Left                (With immediate value)
    * Arithmetic Shift Right            (With immediate value)
    * Logical Shift Right Variable      (With register)
    * Logical Shift Left Variable       (With register)
    * Arithmetic Shift Right Variable   (With register)
* Comparision: (1 instruction)
    * Compare (Sets up the Flags)
* Memory: (10 instructions)
    * Load Word
    * Store Word
    * Load Word increment
    * Store Word increment
    * Load Byte
    * Store Byte
    * Load Byte Increment
    * Store Byte Increment
    * Load Vector
    * Store Vector
* Branch (7 instructions)
    * Unconditional jump
    * Unconditional jump and link
    * Decrement and jump if non zero
    * Branch if zero
    * Branch if non zero
    * Branch if greater (sign flag is 0 and zero flag is 0)
    * Branch if lesser  
* Program control (2 instructions)
    * NOP
    * HALT
* Register Transfer (5 instructions)
    * Load Upper Immediate
    * Conditional Move if zero
    * Conditional Move if non zero
    * Conditional Move if greater
    * Conditional Move if lesser
* Multiplier: (2 instructions)
    * Multiply
    * Multiply and Accumulate
* SIMD: (8 - 10 instructions)
    * Splat 
    * Add
    * Sub
    * And 
    * Or
    * Xor
    * Nor
    * MUL
    * MAC
    *Note: The last two depend on the LUT and CLB usage by the other components*

#!/usr/bin/env python3
"""
Mini RISC Assembler
Generates Vivado-compatible .coe files for instruction and data memories.
Architecture: Harvard Architecture (separate instruction and data memories)
  - instruction.coe: 32-bit Single Port ROM
  - data.coe: 128-bit Port A True Dual Port RAM (Word3_Word2_Word1_Word0)
"""

import sys
import os
import re
import argparse

# -----------------------------------------------------------------------------
# Register Definitions
# -----------------------------------------------------------------------------
SCALAR_REGISTERS = {
    "r0": 0, "r1": 1, "r2": 2, "r3": 3,
    "r4": 4, "r5": 5, "r6": 6, "r7": 7,
    "r8": 8, "r9": 9, "r10": 10, "r11": 11,
    "r12": 12, "rgp": 12, "gp": 12,
    "r13": 13, "rsp": 13, "sp": 13,
    "r14": 14, "rfp": 14, "fp": 14,
    "r15": 15, "rra": 15, "ra": 15,
}

VECTOR_REGISTERS = {}
for i in range(16):
    VECTOR_REGISTERS[f"v{i}"] = i
    VECTOR_REGISTERS[f"vr{i}"] = i


def parse_scalar_reg(token, line_num):
    t = token.strip().lower()
    if t in SCALAR_REGISTERS:
        return SCALAR_REGISTERS[t]
    raise ValueError(f"Line {line_num}: Invalid scalar register '{token}'. Expected r0..r15, rgp, rsp, rfp, rra.")


def parse_vector_reg(token, line_num):
    t = token.strip().lower()
    if t in VECTOR_REGISTERS:
        return VECTOR_REGISTERS[t]
    raise ValueError(f"Line {line_num}: Invalid vector register '{token}'. Expected v0..v15 or vr0..vr15.")


def parse_any_reg(token, line_num):
    t = token.strip().lower()
    if t in SCALAR_REGISTERS:
        return SCALAR_REGISTERS[t], False
    if t in VECTOR_REGISTERS:
        return VECTOR_REGISTERS[t], True
    raise ValueError(f"Line {line_num}: Invalid register '{token}'.")


# -----------------------------------------------------------------------------
# Instruction Encoding Specification
# -----------------------------------------------------------------------------
# R-Type Opcode & Funct definitions
# Format: [31:24] opcode, [23:20] rs, [19:16] rt, [15:12] rd, [11:7] shamt, [6:0] funct
R_TYPE_ALU = {
    # mnemonic: (opcode, funct, format)
    # format: 'alu3' (rd, rs, rt), 'shift_imm' (rd, rs, shamt), 'shift_var' (rd, rs, rt),
    #         'not' (rd, rs), 'cmp' (rs, rt), 'jr' (rs), 'cmov' (rd, rs)
    "add":  (0x16, 0x00, "alu3"),
    "sub":  (0x16, 0x40, "alu3"),
    "and":  (0x17, 0x00, "alu3"),
    "or":   (0x17, 0x08, "alu3"),
    "xor":  (0x17, 0x10, "alu3"),
    "nor":  (0x17, 0x18, "alu3"),
    "not":  (0x17, 0x20, "not"),
    "sll":  (0x15, 0x01, "shift_imm"),
    "srl":  (0x15, 0x02, "shift_imm"),
    "sra":  (0x15, 0x03, "shift_imm"),
    "sllv": (0x15, 0x05, "shift_var"),
    "srlv": (0x15, 0x06, "shift_var"),
    "srav": (0x15, 0x07, "shift_var"),
    "cmp":  (0x12, 0x40, "cmp"),
    "mul":  (0x28, 0x00, "alu3"),
    "mac":  (0x29, 0x00, "alu3"),
    "jr":   (0x20, 0x08, "jr"),
    "cmovz": (0x08, 0x40, "cmov"),
    "cmovn": (0x08, 0x20, "cmov"),
    "cmovg": (0x08, 0x10, "cmov"),
    "cmovl": (0x08, 0x08, "cmov"),
}

R_TYPE_VECTOR = {
    # mnemonic: (opcode, funct, format)
    # Vector-Vector: 'vec3' (vd, vs, vt), 'splat' (vd, rs)
    "addv":  (0x02, 0x00, "vec3"),
    "subv":  (0x02, 0x40, "vec3"),
    "andv":  (0x03, 0x00, "vec3"),
    "orv":   (0x03, 0x10, "vec3"),
    "xorv":  (0x03, 0x20, "vec3"),
    "norv":  (0x03, 0x30, "vec3"),
    "mulv":  (0x2C, 0x00, "vec3"),
    "macv":  (0x2D, 0x00, "vec3"),
    "splat": (0x00, 0x08, "splat"),
    # Vector-Scalar Reductions: 'red' (rd, vs)
    "reds":  (0x06, 0x00, "red"),
    "reda":  (0x07, 0x00, "red"),
    "redo":  (0x07, 0x10, "red"),
    "redx":  (0x07, 0x20, "red"),
    "redn":  (0x07, 0x30, "red"),
}

# I-Type Opcode definitions
# Format: [31:24] opcode, [23:20] rs, [19:16] rt, [15:0] imm
I_TYPE = {
    "addi":  (0x62, "alu_imm"),
    "andi":  (0x63, "alu_imm"),
    "ori":   (0x67, "alu_imm"),
    "xori":  (0x6B, "alu_imm"),
    "nori":  (0x6F, "alu_imm"),
    "lui":   (0x60, "lui"),
    "decj":  (0x6E, "decj"),
    "splati":(0x40, "splati"),
    "lb":    (0x74, "mem_scalar"),
    "sb":    (0x70, "mem_scalar"),
    "lw":    (0x75, "mem_scalar"),
    "sw":    (0x71, "mem_scalar"),
    "lv":    (0x76, "mem_vector"),
    "sv":    (0x72, "mem_vector"),
    "lbi":   (0x7C, "mem_scalar"),
    "sbi":   (0x78, "mem_scalar"),
    "lwi":   (0x7D, "mem_scalar"),
    "swi":   (0x79, "mem_scalar"),
}

# J-Type Opcode definitions
J_TYPE = {
    "j":   (0x81, "jump"),
    "jal": (0x91, "jump"),
    "bz":  (0xA0, "branch"),
    "bn":  (0xA4, "branch"),
    "bg":  (0xA8, "branch"),
    "bl":  (0xAC, "branch"),
}

SPECIAL_INSTRUCTIONS = {
    "nop":  0xC0000000,
    "halt": 0xE0000000,
}


# -----------------------------------------------------------------------------
# Parser Helpers
# -----------------------------------------------------------------------------
def parse_int_literal(token):
    token = token.strip()
    if token.startswith("0x") or token.startswith("0X"):
        return int(token, 16)
    if token.startswith("0b") or token.startswith("0B"):
        return int(token, 2)
    if token.startswith("'") and token.endswith("'") and len(token) >= 3:
        # Character literal
        val = token[1:-1].encode("utf-8").decode("unicode_escape")
        return ord(val[0])
    return int(token, 10)


def parse_mem_operand(token, line_num):
    """
    Parses memory operand syntax:
      - offset(rs)
      - (rs) -> offset = 0
      - rs -> offset = 0
    Returns: (offset_str, base_reg_str)
    """
    token = token.strip()
    m = re.match(r"^([^()]*)\s*\(\s*([^()]+)\s*\)$", token)
    if m:
        offset_str = m.group(1).strip()
        base_reg = m.group(2).strip()
        if not offset_str:
            offset_str = "0"
        return offset_str, base_reg

    # If no parentheses, could be just a register or a label
    if token.lower() in SCALAR_REGISTERS:
        return "0", token

    # Or label with base defaulting to r0
    return token, "r0"


def split_operands(ops_str):
    """
    Splits operand string by commas, respecting string literals.
    """
    if not ops_str.strip():
        return []
    operands = []
    current = []
    in_quote = False
    quote_char = ""
    escaped = False

    for ch in ops_str:
        if escaped:
            current.append(ch)
            escaped = False
            continue
        if ch == "\\":
            current.append(ch)
            escaped = True
            continue
        if in_quote:
            current.append(ch)
            if ch == quote_char:
                in_quote = False
            continue
        if ch in ('"', "'"):
            in_quote = True
            quote_char = ch
            current.append(ch)
            continue
        if ch == ",":
            operands.append("".join(current).strip())
            current = []
            continue
        current.append(ch)

    if current:
        operands.append("".join(current).strip())
    return operands


def parse_escaped_string(s):
    """
    Converts escape sequences in a string like \n, \t, \0, \\, \"
    """
    return bytes(s, "utf-8").decode("unicode_escape")


# -----------------------------------------------------------------------------
# Assembler Implementation
# -----------------------------------------------------------------------------
class Assembler:
    def __init__(self, filepath):
        self.filepath = filepath
        self.filename = os.path.basename(filepath)
        self.data_bytes = bytearray()
        self.data_symbols = {}      # label -> byte_offset
        self.text_symbols = {}      # label -> instruction_index
        self.raw_lines = []
        self.instructions = []      # list of parsed instruction dicts
        self.data_entries_log = []  # for data mapping comments

    def assemble(self):
        with open(self.filepath, "r", encoding="utf-8") as f:
            self.raw_lines = f.readlines()

        # Pass 1: Parse sections, labels, directives, and instructions
        self._pass1()

        # Pass 2: Encode instructions and resolve labels
        assembled_instructions = self._pass2()

        return assembled_instructions

    def _pass1(self):
        current_section = ".text"  # default section
        inst_index = 0
        pending_labels = []

        for line_num, line in enumerate(self.raw_lines, start=1):
            # Strip comments
            # Comments start with ; or # outside quotes
            clean_line = ""
            in_quote = False
            quote_char = ""
            escaped = False
            for ch in line:
                if escaped:
                    clean_line += ch
                    escaped = False
                    continue
                if ch == "\\":
                    clean_line += ch
                    escaped = True
                    continue
                if in_quote:
                    clean_line += ch
                    if ch == quote_char:
                        in_quote = False
                    continue
                if ch in ('"', "'"):
                    in_quote = True
                    quote_char = ch
                    clean_line += ch
                    continue
                if ch in (";", "#"):
                    break
                clean_line += ch

            clean_line = clean_line.strip()
            if not clean_line:
                continue

            # Process labels and directives / instructions on this line
            # A line might have multiple labels, e.g. "L1: L2: add r1, r2, r3"
            while ":" in clean_line:
                # Make sure the colon is not inside a quote
                colon_idx = -1
                in_q = False
                q_char = ""
                for idx, ch in enumerate(clean_line):
                    if in_q:
                        if ch == q_char:
                            in_q = False
                    elif ch in ('"', "'"):
                        in_q = True
                        q_char = ch
                    elif ch == ":":
                        colon_idx = idx
                        break
                if colon_idx == -1:
                    break

                label_candidate = clean_line[:colon_idx].strip()
                # Check if it's a valid label name
                if re.match(r"^[a-zA-Z_][a-zA-Z0-9_]*$", label_candidate):
                    pending_labels.append((label_candidate, line_num))
                    clean_line = clean_line[colon_idx + 1:].strip()
                else:
                    break

            if not clean_line:
                continue

            # Check section switches
            lower_token = clean_line.split()[0].lower()
            if lower_token in (".text", ".code"):
                current_section = ".text"
                rest = clean_line[len(lower_token):].strip()
                if not rest:
                    continue
                clean_line = rest
                lower_token = clean_line.split()[0].lower()
            elif lower_token in (".data", ".rodata", ".bss"):
                current_section = ".data"
                rest = clean_line[len(lower_token):].strip()
                if not rest:
                    continue
                clean_line = rest
                lower_token = clean_line.split()[0].lower()

            # Handle directives in .data or .text
            if clean_line.startswith("."):
                # Check for .align or .balign (supports .align=x, .align = x, .align x)
                if clean_line.startswith(".align") or clean_line.startswith(".balign"):
                    prefix = ".balign" if clean_line.startswith(".balign") else ".align"
                    rest = clean_line[len(prefix):].strip()
                    if rest.startswith("="):
                        rest = rest[1:].strip()
                    if not rest:
                        raise ValueError(f"Line {line_num}: .align directive requires a value, e.g. .align=2")
                    shift_val = parse_int_literal(rest)
                    if shift_val < 0 or shift_val > 30:
                        raise ValueError(f"Line {line_num}: .align={shift_val} out of range (0..30).")
                    boundary = 1 << shift_val

                    if current_section == ".data":
                        rem = len(self.data_bytes) % boundary
                        if rem != 0:
                            self.data_bytes.extend(b"\x00" * (boundary - rem))
                    else: # .text section
                        rem = (inst_index * 4) % boundary
                        if rem != 0:
                            nops_needed = (boundary - rem) // 4
                            for _ in range(nops_needed):
                                self.instructions.append({
                                    "index": inst_index,
                                    "line_num": line_num,
                                    "raw_text": "nop (alignment)",
                                    "labels": [],
                                    "mnemonic": "nop",
                                    "operands": [],
                                })
                                inst_index += 1
                    continue

                # Directive
                parts = clean_line.split(maxsplit=1)
                directive = parts[0].lower()
                arg_str = parts[1] if len(parts) > 1 else ""

                if current_section == ".data":
                    # Attach pending labels to current data byte offset
                    cur_offset = len(self.data_bytes)
                    for lbl, lbl_line in pending_labels:
                        if lbl in self.data_symbols or lbl in self.text_symbols:
                            raise ValueError(f"Line {lbl_line}: Duplicate symbol '{lbl}'")
                        self.data_symbols[lbl] = cur_offset
                        self.data_entries_log.append((lbl, cur_offset))
                    pending_labels = []

                    self._handle_data_directive(directive, arg_str, line_num)
                else:
                    raise ValueError(f"Line {line_num}: Directive '{directive}' not supported in .text section.")
                continue

            # It's an instruction in .text
            if current_section != ".text":
                raise ValueError(f"Line {line_num}: Instruction '{clean_line}' found in .data section. Use .text first.")

            # Assign pending labels to this instruction index
            cur_labels = [lbl for lbl, _ in pending_labels]
            for lbl, lbl_line in pending_labels:
                if lbl in self.data_symbols or lbl in self.text_symbols:
                    raise ValueError(f"Line {lbl_line}: Duplicate symbol '{lbl}'")
                self.text_symbols[lbl] = inst_index
            pending_labels = []

            # Parse instruction
            parts = clean_line.split(maxsplit=1)
            mnemonic = parts[0].lower()
            ops_str = parts[1] if len(parts) > 1 else ""
            operands = split_operands(ops_str)

            self.instructions.append({
                "index": inst_index,
                "line_num": line_num,
                "raw_text": clean_line,
                "labels": cur_labels,
                "mnemonic": mnemonic,
                "operands": operands,
            })
            inst_index += 1

        # Check for trailing pending labels
        for lbl, lbl_line in pending_labels:
            if current_section == ".data":
                self.data_symbols[lbl] = len(self.data_bytes)
            else:
                self.text_symbols[lbl] = inst_index

    def _handle_data_directive(self, directive, arg_str, line_num):
        args = split_operands(arg_str)
        if directive == ".word":
            for a in args:
                val = self._eval_immediate(a, line_num, allow_unresolved=True)
                if val is None:
                    # Defer or resolve: in .data, numeric literals or previously defined labels
                    raise ValueError(f"Line {line_num}: Forward label reference '{a}' in .data not supported.")
                self.data_bytes.extend(int(val & 0xFFFFFFFF).to_bytes(4, byteorder="little", signed=False))

        elif directive in (".half", ".short"):
            for a in args:
                val = parse_int_literal(a)
                self.data_bytes.extend(int(val & 0xFFFF).to_bytes(2, byteorder="little", signed=False))

        elif directive == ".byte":
            for a in args:
                val = parse_int_literal(a)
                self.data_bytes.append(val & 0xFF)

        elif directive == ".asciiz":
            if not (arg_str.startswith('"') and arg_str.endswith('"')):
                raise ValueError(f"Line {line_num}: .asciiz expects quoted string.")
            content = parse_escaped_string(arg_str[1:-1])
            self.data_bytes.extend(content.encode("utf-8") + b"\x00")

        elif directive == ".ascii":
            if not (arg_str.startswith('"') and arg_str.endswith('"')):
                raise ValueError(f"Line {line_num}: .ascii expects quoted string.")
            content = parse_escaped_string(arg_str[1:-1])
            self.data_bytes.extend(content.encode("utf-8"))

        elif directive in (".space", ".zero", ".fill"):
            count = parse_int_literal(args[0])
            self.data_bytes.extend(b"\x00" * count)

        elif directive == ".vec":
            # 128-bit vector constant (16 bytes)
            if len(args) == 4:
                # 4 32-bit words: word0, word1, word2, word3
                for a in args:
                    val = parse_int_literal(a)
                    self.data_bytes.extend(int(val & 0xFFFFFFFF).to_bytes(4, byteorder="little", signed=False))
            elif len(args) == 1:
                # 128-bit integer/hex
                val = parse_int_literal(args[0])
                self.data_bytes.extend(int(val & ((1 << 128) - 1)).to_bytes(16, byteorder="little", signed=False))
            else:
                raise ValueError(f"Line {line_num}: .vec takes either 4 32-bit words or one 128-bit hex literal.")
        else:
            raise ValueError(f"Line {line_num}: Unknown data directive '{directive}'.")

    def _eval_immediate(self, token, line_num, allow_unresolved=False):
        token = token.strip()
        try:
            return parse_int_literal(token)
        except ValueError:
            pass

        # Check data symbols
        if token in self.data_symbols:
            return self.data_symbols[token]

        # Check text symbols
        if token in self.text_symbols:
            return self.text_symbols[token]

        if allow_unresolved:
            return None
        raise ValueError(f"Line {line_num}: Undefined label or invalid immediate '{token}'.")

    def _pass2(self):
        assembled = []
        for inst in self.instructions:
            idx = inst["index"]
            line_num = inst["line_num"]
            mnemonic = inst["mnemonic"]
            operands = inst["operands"]
            raw_text = inst["raw_text"]
            labels = inst["labels"]

            word, comment_note = self._encode_instruction(mnemonic, operands, idx, line_num)

            assembled.append({
                "index": idx,
                "word": word,
                "hex": f"{word:08X}",
                "raw_text": raw_text,
                "labels": labels,
                "note": comment_note,
            })
        return assembled

    def _encode_instruction(self, mnemonic, operands, idx, line_num):
        # 1. Special Instructions (NOP, HALT)
        if mnemonic in SPECIAL_INSTRUCTIONS:
            if operands:
                raise ValueError(f"Line {line_num}: '{mnemonic}' takes no operands.")
            return SPECIAL_INSTRUCTIONS[mnemonic], ""

        # 2. R-Type ALU Instructions
        if mnemonic in R_TYPE_ALU:
            opcode, funct, fmt = R_TYPE_ALU[mnemonic]
            rs, rt, rd, shamt = 0, 0, 0, 0
            note = ""

            if fmt == "alu3":
                # mnemonic rd, rs, rt
                if len(operands) != 3:
                    raise ValueError(f"Line {line_num}: '{mnemonic}' expects 3 operands: rd, rs, rt.")
                rd = parse_scalar_reg(operands[0], line_num)
                rs = parse_scalar_reg(operands[1], line_num)
                rt = parse_scalar_reg(operands[2], line_num)

            elif fmt == "shift_imm":
                # mnemonic rd, rs, shamt
                if len(operands) != 3:
                    raise ValueError(f"Line {line_num}: '{mnemonic}' expects 3 operands: rd, rs, shamt.")
                rd = parse_scalar_reg(operands[0], line_num)
                rs = parse_scalar_reg(operands[1], line_num)
                shamt_val = self._eval_immediate(operands[2], line_num)
                if not (0 <= shamt_val <= 31):
                    raise ValueError(f"Line {line_num}: Shift amount {shamt_val} out of range (0..31).")
                shamt = shamt_val & 0x1F
                rt = 0

            elif fmt == "shift_var":
                # mnemonic rd, rs, rt
                if len(operands) != 3:
                    raise ValueError(f"Line {line_num}: '{mnemonic}' expects 3 operands: rd, rs, rt.")
                rd = parse_scalar_reg(operands[0], line_num)
                rs = parse_scalar_reg(operands[1], line_num)
                rt = parse_scalar_reg(operands[2], line_num)

            elif fmt == "not":
                # not rd, rs (rt = 0)
                if len(operands) != 2:
                    raise ValueError(f"Line {line_num}: 'not' expects 2 operands: rd, rs.")
                rd = parse_scalar_reg(operands[0], line_num)
                rs = parse_scalar_reg(operands[1], line_num)
                rt = 0

            elif fmt == "cmp":
                # cmp rs, rt (rd = 0)
                if len(operands) != 2:
                    raise ValueError(f"Line {line_num}: 'cmp' expects 2 operands: rs, rt.")
                rs = parse_scalar_reg(operands[0], line_num)
                rt = parse_scalar_reg(operands[1], line_num)
                rd = 0

            elif fmt == "jr":
                # jr rs (rt = 0, rd = 0)
                if len(operands) != 1:
                    raise ValueError(f"Line {line_num}: 'jr' expects 1 operand: rs.")
                rs = parse_scalar_reg(operands[0], line_num)
                rt = 0
                rd = 0

            elif fmt == "cmov":
                # cmovz/cmovn/cmovg/cmovl rd, rs (rt = 0)
                if len(operands) != 2:
                    raise ValueError(f"Line {line_num}: '{mnemonic}' expects 2 operands: rd, rs.")
                rd = parse_scalar_reg(operands[0], line_num)
                rs = parse_scalar_reg(operands[1], line_num)
                rt = 0

            word = (opcode << 24) | (rs << 20) | (rt << 16) | (rd << 12) | (shamt << 7) | (funct & 0x7F)
            return word, note

        # 3. R-Type Vector Instructions
        if mnemonic in R_TYPE_VECTOR:
            opcode, funct, fmt = R_TYPE_VECTOR[mnemonic]
            vs, vt, vd, rd = 0, 0, 0, 0
            note = ""

            if fmt == "vec3":
                # mnemonic vd, vs, vt
                if len(operands) != 3:
                    raise ValueError(f"Line {line_num}: '{mnemonic}' expects 3 operands: vd, vs, vt.")
                vd = parse_vector_reg(operands[0], line_num)
                vs = parse_vector_reg(operands[1], line_num)
                vt = parse_vector_reg(operands[2], line_num)
                dest = vd

            elif fmt == "splat":
                # splat vd, rs
                if len(operands) != 2:
                    raise ValueError(f"Line {line_num}: 'splat' expects 2 operands: vd, rs.")
                vd = parse_vector_reg(operands[0], line_num)
                vs = parse_scalar_reg(operands[1], line_num)
                vt = 0
                dest = vd

            elif fmt == "red":
                # reds rd, vs (vt = 0)
                if len(operands) != 2:
                    raise ValueError(f"Line {line_num}: '{mnemonic}' expects 2 operands: rd, vs.")
                rd = parse_scalar_reg(operands[0], line_num)
                vs = parse_vector_reg(operands[1], line_num)
                vt = 0
                dest = rd

            word = (opcode << 24) | (vs << 20) | (vt << 16) | (dest << 12) | (funct & 0x7F)
            return word, note

        # 4. I-Type Instructions
        if mnemonic in I_TYPE:
            opcode, fmt = I_TYPE[mnemonic]
            rs, rt = 0, 0
            imm = 0
            note = ""

            if fmt == "alu_imm":
                # mnemonic rt, rs, imm
                if len(operands) != 3:
                    raise ValueError(f"Line {line_num}: '{mnemonic}' expects 3 operands: rt, rs, imm.")
                rt = parse_scalar_reg(operands[0], line_num)
                rs = parse_scalar_reg(operands[1], line_num)
                imm_token = operands[2]
                imm_val = self._eval_immediate(imm_token, line_num)
                imm = imm_val & 0xFFFF
                if imm_token in self.data_symbols or imm_token in self.text_symbols:
                    note = f"(0x{imm:04X})"

            elif fmt == "lui":
                # lui rt, imm (rs = 0)
                if len(operands) != 2:
                    raise ValueError(f"Line {line_num}: 'lui' expects 2 operands: rt, imm.")
                rt = parse_scalar_reg(operands[0], line_num)
                rs = 0
                imm_token = operands[1]
                imm_val = self._eval_immediate(imm_token, line_num)
                imm = imm_val & 0xFFFF
                if imm_token in self.data_symbols or imm_token in self.text_symbols:
                    note = f"(0x{imm:04X})"

            elif fmt == "decj":
                # decj rs, label (rt = 0)
                # Jump formula: next_pc = {pc[31:2] + 1 + imm, 2'b00} => imm = target - (pc + 1)
                if len(operands) != 2:
                    raise ValueError(f"Line {line_num}: 'decj' expects 2 operands: rs, label.")
                rs = parse_scalar_reg(operands[0], line_num)
                rt = 0
                target_token = operands[1]
                if target_token in self.text_symbols:
                    target_idx = self.text_symbols[target_token]
                    offset = target_idx - (idx + 1)
                    imm = offset & 0xFFFF
                    note = f"(imm = {offset} -> 0x{imm:04X})"
                else:
                    imm_val = self._eval_immediate(target_token, line_num)
                    imm = imm_val & 0xFFFF

            elif fmt == "splati":
                # splati vd, imm (rs = 0, rt = vd)
                if len(operands) != 2:
                    raise ValueError(f"Line {line_num}: 'splati' expects 2 operands: vd, imm.")
                rt = parse_vector_reg(operands[0], line_num)
                rs = 0
                imm_token = operands[1]
                imm_val = self._eval_immediate(imm_token, line_num)
                imm = imm_val & 0xFFFF

            elif fmt in ("mem_scalar", "mem_vector"):
                # load/store: mnemonic reg, offset(rs)
                if len(operands) != 2:
                    raise ValueError(f"Line {line_num}: '{mnemonic}' expects 2 operands: reg, offset(rs).")
                if fmt == "mem_vector":
                    rt = parse_vector_reg(operands[0], line_num)
                else:
                    rt = parse_scalar_reg(operands[0], line_num)

                offset_str, base_reg_str = parse_mem_operand(operands[1], line_num)
                rs = parse_scalar_reg(base_reg_str, line_num)
                imm_val = self._eval_immediate(offset_str, line_num)
                imm = imm_val & 0xFFFF
                if offset_str in self.data_symbols or offset_str in self.text_symbols:
                    note = f"(0x{imm:04X})"

            word = (opcode << 24) | (rs << 20) | (rt << 16) | imm
            return word, note

        # 5. J-Type Instructions
        if mnemonic in J_TYPE:
            opcode, fmt = J_TYPE[mnemonic]
            if len(operands) != 1:
                raise ValueError(f"Line {line_num}: '{mnemonic}' expects 1 operand: target.")
            target_token = operands[0]

            if fmt == "jump":
                # J, JAL: [31:24] opcode, [23:0] jta
                # pc_1 = pc[31:2] + 1; next_pc = {pc_1[29:24], jta[23:0], 2'b00}
                if target_token in self.text_symbols:
                    target_idx = self.text_symbols[target_token]
                    jta = target_idx & 0xFFFFFF
                    note = f"(jta = 0x{jta:06X})"
                else:
                    target_val = self._eval_immediate(target_token, line_num)
                    jta = target_val & 0xFFFFFF
                word = (opcode << 24) | jta
                return word, note

            elif fmt == "branch":
                # BZ, BN, BG, BL: [31:24] opcode, [23:16] 0x00, [15:0] imm
                # next_pc = {pc[31:2] + 1 + imm, 2'b00} => imm = target - (pc + 1)
                if target_token in self.text_symbols:
                    target_idx = self.text_symbols[target_token]
                    offset = target_idx - (idx + 1)
                    imm = offset & 0xFFFF
                    note = f"(imm = {offset} -> 0x{imm:04X})"
                else:
                    target_val = self._eval_immediate(target_token, line_num)
                    imm = target_val & 0xFFFF
                word = (opcode << 24) | imm
                return word, note

        raise ValueError(f"Line {line_num}: Unknown mnemonic '{mnemonic}'.")

    # -------------------------------------------------------------------------
    # COE Output Generators
    # -------------------------------------------------------------------------
    def generate_instruction_coe(self, assembled_instructions, pad_depth=0):
        lines = []
        lines.append("; =========================================================================")
        lines.append("; Mini RISC Instruction Memory Initialization (instruction.coe)")
        lines.append(f"; Assembled from {self.filename}")
        lines.append("; Radix: Hexadecimal (32-bit instructions)")
        lines.append("; =========================================================================")
        lines.append(";")
        lines.append("; Instruction Mapping:")

        for item in assembled_instructions:
            idx = item["index"]
            hex_str = item["hex"]
            raw_text = item["raw_text"]
            labels = item["labels"]
            note = item["note"]

            # Format assembly text
            mapping_line = f"; [{idx}]".ljust(7) + f" {hex_str} : {raw_text}"
            if note:
                mapping_line += f"         {note}"
            if labels:
                mapping_line += f"  <-- {', '.join(labels)}"
            lines.append(mapping_line)

        lines.append("; =========================================================================")
        lines.append("")
        lines.append("memory_initialization_radix = 16;")
        lines.append("memory_initialization_vector =")

        words = [item["hex"] for item in assembled_instructions]
        if pad_depth > len(words):
            words.extend(["00000000"] * (pad_depth - len(words)))

        if not words:
            words = ["00000000"]

        for i, w in enumerate(words):
            separator = ";" if i == len(words) - 1 else ","
            lines.append(f"{w}{separator}")

        return "\n".join(lines) + "\n"

    def generate_data_coe(self, pad_depth=0):
        lines = []
        lines.append("; =========================================================================")
        lines.append("; Mini RISC Data Memory Initialization (data.coe)")
        lines.append(f"; Assembled from {self.filename}")
        lines.append("; Port A Width: 128-bit (4 x 32-bit words per line, little-endian: Word3_Word2_Word1_Word0)")
        lines.append("; Port B Width: 32-bit (word-addressed at Port B, byte-addressed by processor via EA >> 2)")
        lines.append("; =========================================================================")
        lines.append(";")

        # Data mapping comment
        if self.data_symbols:
            lines.append("; Data Mapping:")
            sorted_symbols = sorted(self.data_symbols.items(), key=lambda x: x[1])
            for lbl, offset in sorted_symbols:
                lines.append(f"; [0x{offset:04X}] {lbl}")
            lines.append("; =========================================================================")
        else:
            lines.append("; Data Mapping: (empty)")
            lines.append("; =========================================================================")

        lines.append("")
        lines.append("memory_initialization_radix = 16;")
        lines.append("memory_initialization_vector =")

        # Pack into 128-bit words: Word3_Word2_Word1_Word0
        # Each line has 16 bytes = 4 words of 4 bytes each.
        data = bytearray(self.data_bytes)
        rem = len(data) % 16
        if rem != 0:
            data.extend(b"\x00" * (16 - rem))

        lines_128 = []
        total_lines = len(data) // 16
        for i in range(total_lines):
            block = data[i * 16 : (i + 1) * 16]
            w0 = int.from_bytes(block[0:4], byteorder="little", signed=False)
            w1 = int.from_bytes(block[4:8], byteorder="little", signed=False)
            w2 = int.from_bytes(block[8:12], byteorder="little", signed=False)
            w3 = int.from_bytes(block[12:16], byteorder="little", signed=False)
            # Line is Word3_Word2_Word1_Word0
            line_hex = f"{w3:08X}{w2:08X}{w1:08X}{w0:08X}"
            lines_128.append(line_hex)

        if pad_depth > len(lines_128):
            lines_128.extend(["00000000000000000000000000000000"] * (pad_depth - len(lines_128)))

        if not lines_128:
            lines_128 = ["00000000000000000000000000000000"]

        for i, l in enumerate(lines_128):
            separator = ";" if i == len(lines_128) - 1 else ","
            lines.append(f"{l}{separator}")

        return "\n".join(lines) + "\n"


# -----------------------------------------------------------------------------
# Main CLI Entry Point
# -----------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(
        description="Assembler for Mini RISC Harvard Architecture ISA."
    )
    parser.add_argument("source", help="Input assembly file (.asm / .s)")
    parser.add_argument("-o", "--outdir", default=".", help="Output directory for .coe files (default: current directory)")
    parser.add_argument("--inst-coe", default="instruction.coe", help="Output filename for instruction memory (default: instruction.coe)")
    parser.add_argument("--data-coe", default="data.coe", help="Output filename for data memory (default: data.coe)")
    parser.add_argument("--pad-inst", type=int, default=0, help="Pad instruction memory to specified depth")
    parser.add_argument("--pad-data", type=int, default=0, help="Pad data memory to specified depth")

    args = parser.parse_args()

    if not os.path.exists(args.source):
        print(f"Error: Source file '{args.source}' not found.", file=sys.stderr)
        sys.exit(1)

    try:
        assembler = Assembler(args.source)
        assembled = assembler.assemble()

        os.makedirs(args.outdir, exist_ok=True)
        inst_path = os.path.join(args.outdir, args.inst_coe)
        data_path = os.path.join(args.outdir, args.data_coe)

        inst_content = assembler.generate_instruction_coe(assembled, pad_depth=args.pad_inst)
        data_content = assembler.generate_data_coe(pad_depth=args.pad_data)

        with open(inst_path, "w", encoding="utf-8") as f:
            f.write(inst_content)

        with open(data_path, "w", encoding="utf-8") as f:
            f.write(data_content)

        print(f"Assembly successful:")
        print(f"  Instructions assembled: {len(assembled)}")
        print(f"  Data memory bytes:      {len(assembler.data_bytes)}")
        print(f"  Generated: {inst_path}")
        print(f"  Generated: {data_path}")

    except Exception as e:
        print(f"Assembly Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()

/* ------------------------------------------------------------
 *  Group Number: 62
 *  Group Members (Name and Roll Number):
 *  1. Priyansh Pranjal     24CS10024
 *  2. Allu Gowri Sasaank   24CS10054
 *  Course: Computer Organization and Architecture Laboratory
 *  Assignment: Verilog Assignment 1
 *  Question: 1
 *  Problem: Hierarchical Design of a 4-bit Combinational Logic Unit
 *  Module: logic_unit
 *  Date: 12-8-2026
 * ------------------------------------------------------------
 */

module logic_unit (
    output wire [4:0] Y,
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire [1:0] sel
);
  wire [4:0] I0, I1, I2, I3;

  ripple_carry_adder_4bit RCA (
      .Sum(I0),
      .A  (A),
      .B  (B)
  );

  and_4bit AND (
      .Y(I1),
      .A(A),
      .B(B)
  );

  or_4bit OR (
      .Y(I2),
      .A(A),
      .B(B)
  );

  xor_4bit XOR (
      .Y(I3),
      .A(A),
      .B(B)
  );

  mux4to1_5bit MUX (
      .Y  (Y),
      .I0 (I0),
      .I1 (I1),
      .I2 (I2),
      .I3 (I3),
      .sel(sel)
  );
endmodule

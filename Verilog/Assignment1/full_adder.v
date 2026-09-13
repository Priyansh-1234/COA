/* ------------------------------------------------------------
 *  Group Number: 62
 *  Group Members (Name and Roll Number):
 *  1. Priyansh Pranjal     24CS10024
 *  2. Allu Gowri Sasaank   24CS10054
 *  Course: Computer Organization and Architecture Laboratory
 *  Assignment: Verilog Assignment 1
 *  Question: 1
 *  Problem: Hierarchical Design of a 4-bit Combinational Logic Unit
 *  Module: full_adder
 *  Date: 12-8-2026
 * ------------------------------------------------------------
 */
module full_adder (
    output wire Sum,
    output wire Cout,
    input  wire A,
    input  wire B,
    input  wire Cin
);
  wire int_sum, carry1, carry2;

  half_adder HA1 (
      .Sum(int_sum),
      .Carry(carry1),
      .A(A),
      .B(B)
  );

  half_adder HA2 (
      .Sum(Sum),
      .Carry(carry2),
      .A(int_sum),
      .B(Cin)
  );

  assign Cout = carry1 | carry2;
endmodule

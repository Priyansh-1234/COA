/* ------------------------------------------------------------
 *  Group Number: 62
 *  Group Members (Name and Roll Number):
 *  1. Priyansh Pranjal     24CS10024
 *  2. Allu Gowri Sasaank   24CS10054
 *  Course: Computer Organization and Architecture Laboratory
 *  Assignment: Verilog Assignment 1
 *  Question: 1
 *  Problem: Hierarchical Design of a 4-bit Combinational Logic Unit
 *  Module: ripple_carry_adder_4bit
 *  Date: 12-8-2026
 * ------------------------------------------------------------
 */
module ripple_carry_adder_4bit (
    output wire [4:0] Sum,
    input  wire [3:0] A,
    input  wire [3:0] B
);
  wire carry0, carry1, carry2;
  full_adder FA0 (
      .Sum(Sum[0]),
      .Cout(carry0),
      .A(A[0]),
      .B(B[0]),
      .Cin(0)
  );
  full_adder FA1 (
      .Sum(Sum[1]),
      .Cout(carry1),
      .A(A[1]),
      .B(B[1]),
      .Cin(carry0)
  );
  full_adder FA2 (
      .Sum(Sum[2]),
      .Cout(carry2),
      .A(A[2]),
      .B(B[2]),
      .Cin(carry1)
  );
  full_adder FA3 (
      .Sum(Sum[3]),
      .Cout(Sum[4]),
      .A(A[3]),
      .B(B[3]),
      .Cin(carry2)
  );
endmodule

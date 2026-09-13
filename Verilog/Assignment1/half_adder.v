/* ------------------------------------------------------------
 *  Group Number: 62
 *  Group Members (Name and Roll Number):
 *  1. Priyansh Pranjal     24CS10024
 *  2. Allu Gowri Sasaank   24CS10054
 *  Course: Computer Organization and Architecture Laboratory
 *  Assignment: Verilog Assignment 1
 *  Question: 1
 *  Problem: Hierarchical Design of a 4-bit Combinational Logic Unit
 *  Module: half_adder
 *  Date: 12-8-2026
 * ------------------------------------------------------------
 */

module half_adder (
    output wire Sum,
    output wire Carry,
    input  wire A,
    input  wire B
);
  assign Sum   = A ^ B;
  assign Carry = A & B;
endmodule

/* ------------------------------------------------------------
 *  Group Number: 62
 *  Group Members (Name and Roll Number):
 *  1. Priyansh Pranjal     24CS10024
 *  2. Allu Gowri Sasaank   24CS10054
 *  Course: Computer Organization and Architecture Laboratory
 *  Assignment: Verilog Assignment 1
 *  Question: 1
 *  Problem: Hierarchical Design of a 4-bit Combinational Logic Unit
 *  Module: or_4bit
 *  Date: 12-8-2026
 * ------------------------------------------------------------
 */
module or_4bit (
    output wire [4:0] Y,
    input  wire [3:0] A,
    input  wire [3:0] B
);
  assign Y[4] = 0;
  assign Y[3] = A[3] | B[3];
  assign Y[2] = A[2] | B[2];
  assign Y[1] = A[1] | B[1];
  assign Y[0] = A[0] | B[0];
endmodule


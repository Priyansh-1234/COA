/* ------------------------------------------------------------
 *  Group Number: 62
 *  Group Members (Name and Roll Number):
 *  1. Priyansh Pranjal     24CS10024
 *  2. Allu Gowri Sasaank   24CS10054
 *  Course: Computer Organization and Architecture Laboratory
 *  Assignment: Verilog Assignment 1
 *  Question: 1
 *  Problem: Hierarchical Design of a 4-bit Combinational Logic Unit
 *  Module: mux4to1_5bit
 *  Date: 12-8-2026
 * ------------------------------------------------------------
 */

module mux4to1_5bit (
    output reg  [4:0] Y,
    input  wire [4:0] I0,
    input  wire [4:0] I1,
    input  wire [4:0] I2,
    input  wire [4:0] I3,
    input  wire [1:0] sel
);
  always @(sel or I0 or I1 or I2 or I3) begin
    case (sel)
      2'b00:   Y = I0;
      2'b01:   Y = I1;
      2'b10:   Y = I2;
      2'b11:   Y = I3;
      default: Y = 2'bxx;
    endcase
  end
endmodule

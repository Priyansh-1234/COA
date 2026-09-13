// <====================================>
//  Group No.           : 62
//  Group Members       :
//                        * Priyansh Pranjal     24CS10024
//                        * Allu Gowri Sasaank   24CS10054
//
//  Assignment Name     : 32-bit Signed Fast Booth Multiplier Using Carry-Save Reduction
//  Module Name         : carry_save_adder_64
//  Date of Submission  : 07-09-2026
// <====================================>

module carry_save_adder_64 (
    input  wire [63:0] X,
    input  wire [63:0] Y,
    input  wire [63:0] Z,
    output wire [63:0] S,
    output wire [63:0] C
);
  assign S = X ^ Y ^ Z;
  assign C = (X & Y) | (Y & Z) | (Z & X);
endmodule

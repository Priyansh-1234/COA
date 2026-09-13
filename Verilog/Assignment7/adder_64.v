// <====================================>
//  Group No.           : 62
//  Group Members       :
//                        * Priyansh Pranjal     24CS10024
//                        * Allu Gowri Sasaank   24CS10054
//
//  Assignment Name     : 32-bit Signed Fast Booth Multiplier Using Carry-Save Reduction
//  Module Name         : adder_64
//  Date of Submission  : 07-09-2026
// <====================================>

module adder_64 (
    input  wire [63:0] A,
    input  wire [63:0] B,
    output wire [63:0] C
);
  assign C = A + B;
endmodule


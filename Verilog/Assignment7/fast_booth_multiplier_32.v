// <====================================>
//  Group No.           : 62
//  Group Members       :
//                        * Priyansh Pranjal     24CS10024
//                        * Allu Gowri Sasaank   24CS10054
//
//  Assignment Name     : 32-bit Signed Fast Booth Multiplier Using Carry-Save Reduction
//  Module Name         : fast_booth_multiplier_32
//  Date of Submission  : 07-09-2026
// <====================================>
module fast_booth_multiplier_32 (
    input  wire               clk,
    input  wire               reset,
    input  wire               start,
    input  wire signed [31:0] multiplicand,
    input  wire signed [31:0] multiplier,
    output wire signed [63:0] product,
    output wire               busy,
    output wire               done
);
  wire load_inputs;
  wire load_product;

  fast_booth_controlpath control_path (
      .clk         (clk),
      .reset       (reset),
      .start       (start),
      .busy        (busy),
      .done        (done),
      .load_inputs (load_inputs),
      .load_product(load_product)
  );

  fast_booth_datapath data_path (
      .clk         (clk),
      .reset       (reset),
      .load_inputs (load_inputs),
      .load_product(load_product),
      .multiplicand(multiplicand),
      .multiplier  (multiplier),
      .product     (product)
  );
endmodule

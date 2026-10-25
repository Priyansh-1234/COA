module fast_booth_multiplier (
    input  wire               clk,
    input  wire               rst,
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
      .rst         (rst),
      .start       (start),
      .busy        (busy),
      .done        (done),
      .load_inputs (load_inputs),
      .load_product(load_product)
  );

  fast_booth_datapath datapath (
      .clk         (clk),
      .rst         (rst),
      .load_inputs (load_inputs),
      .load_product(load_product),
      .multiplicand(multiplicand),
      .multiplier  (multiplier),
      .product     (product)
  );
endmodule

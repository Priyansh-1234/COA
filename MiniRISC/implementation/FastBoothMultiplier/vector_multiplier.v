module vector_multiplier (
    input  wire               clk,
    input  wire               rst,
    input  wire               start,
    input  wire signed [127:0] multiplicand,
    input  wire signed [127:0] multiplier,
    output wire signed [127:0] product,
    output wire               busy,
    output wire               done
);

  wire [3:0] done_lanes;
  wire [3:0] busy_lanes;
  wire signed [63:0] prod_lane[0:3];

  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : gen_mult_lanes
      fast_booth_multiplier lane_mult (
          .clk         (clk),
          .rst         (rst),
          .start       (start),
          .multiplicand(multiplicand[32*(3-i)+:32]),
          .multiplier  (multiplier[32*(3-i)+:32]),
          .product     (prod_lane[i]),
          .busy        (busy_lanes[i]),
          .done        (done_lanes[i])
      );
    end
  endgenerate

  assign product = {prod_lane[0][31:0], prod_lane[1][31:0], prod_lane[2][31:0], prod_lane[3][31:0]};
  assign done    = done_lanes[0] & done_lanes[1] & done_lanes[2] & done_lanes[3];
  assign busy    = busy_lanes[0] | busy_lanes[1] | busy_lanes[2] | busy_lanes[3];

endmodule

module partial_product_generator (
    input  wire signed [31:0] multiplicand,
    input  wire        [ 3:0] index,
    input  wire               zero,
    input  wire               negate,
    input  wire               double,
    output reg signed  [63:0] partial_product
);
  wire [63:0] sign_extended = {{32{multiplicand[31]}}, multiplicand};
  reg  [63:0] temp;

  always @(*) begin
    if (zero) begin
      partial_product = 64'd0;
    end else begin

      if (double) begin
        temp = sign_extended << 1;
      end else begin
        temp = sign_extended;
      end

      if (negate) begin
        temp = ~temp;
      end else begin
        temp = temp;
      end

      partial_product = temp << (2 * index);
    end
  end
endmodule

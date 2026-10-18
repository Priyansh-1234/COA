module shifter (
    input  wire signed [31:0] input1,
    input  wire        [ 4:0] amt,
    input  wire        [ 1:0] shift_func,
    output reg signed  [31:0] result
);
  always @(*) begin
    case (shift_func)
      2'b00: result = input1;
      2'b01: result = input1 << amt;
      2'b10: result = input1 >> amt;
      2'b11: result = input1 >>> amt;
    endcase
  end
endmodule

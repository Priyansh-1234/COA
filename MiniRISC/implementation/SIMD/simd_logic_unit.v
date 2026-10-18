module simd_logic_unit (
    input  wire [31:0] input1,
    input  wire [31:0] input2,
    input  wire [ 1:0] logic_func,
    output reg  [31:0] result
);
  always @(*) begin
    case (logic_func)
      2'b00:   result = input1 & input2;
      2'b01:   result = input1 | input2;
      2'b10:   result = input1 ^ input2;
      2'b11:   result = ~(input1 | input2);
      default: result = 32'd0;
    endcase
  end
endmodule

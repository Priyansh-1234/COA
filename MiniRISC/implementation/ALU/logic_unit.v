module logic_unit (
    input  wire [31:0] input1,
    input  wire [31:0] input2,
    input  wire [ 2:0] logic_func,
    output reg  [31:0] result
);
  always @(*) begin
    case (logic_func)
      3'b000:  result = input1 & input2;
      3'b001:  result = input1 | input2;
      3'b010:  result = input1 ^ input2;
      3'b011:  result = ~(input1 | input2);
      3'b100:  result = ~input1;
      default: result = 32'b0;
    endcase
  end
endmodule

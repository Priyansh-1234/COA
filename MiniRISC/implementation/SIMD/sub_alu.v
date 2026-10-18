module sub_alu (
    input  wire signed [31:0] input1,
    input  wire signed [31:0] input2,
    input  wire signed [31:0] rs,
    input  wire signed [31:0] imm,
    input  wire               add_bar_sub,
    input  wire               splat_src,
    input  wire        [ 1:0] logic_func,
    input  wire        [ 1:0] func_class,
    output reg signed  [31:0] result
);

  reg signed  [31:0] adder_input2;
  wire signed [31:0] adder_result;
  always @(*) begin
    if (add_bar_sub == 0) begin
      adder_input2 = input2;
    end else begin
      adder_input2 = ~input2;
    end
  end
  simd_adder a (
      .input1(input1),
      .input2(adder_input2),
      .C_in  (add_bar_sub),
      .result(adder_result)
  );

  wire [31:0] logic_result;
  simd_logic_unit l (
      .input1    (input1),
      .input2    (input2),
      .logic_func(logic_func),
      .result    (logic_result)
  );

  wire [31:0] splat_result;
  assign splat_result = (splat_src == 0) ? imm : rs;

  always @(*) begin
    case (func_class)
      2'b00:   result = splat_result;
      2'b10:   result = adder_result;
      2'b11:   result = logic_result;
      default: result = 32'd0;
    endcase
  end
endmodule

module alu (
    input  wire               clk,
    input  wire               rst,
    input  wire signed [31:0] input1,
    input  wire signed [31:0] input2,
    input  wire        [ 4:0] shamt,
    input  wire               add_bar_sub,
    input  wire               shift_src,
    input  wire        [ 1:0] shift_func,
    input  wire        [ 2:0] logic_func,
    input  wire        [ 1:0] func_class,
    output wire               zero_flag,
    output wire               sign_flag,
    output reg signed  [31:0] result
);
  wire signed [31:0] padder_result;
  padder p (
      .input1(input2),
      .result(padder_result)
  );

  wire signed [31:0] shifter_result;
  reg [4:0] amt;
  always @(*) begin
    if (shift_src == 0) begin
      amt = shamt;
    end else begin
      amt = input2[4:0];
    end
  end
  shifter s (
      .input1    (input1),
      .amt       (amt),
      .shift_func(shift_func),
      .result    (shifter_result)
  );

  wire signed [31:0] adder_result;
  reg signed  [31:0] adder_input2;
  always @(*) begin
    if (add_bar_sub == 0) begin
      adder_input2 = input2;
    end else begin
      adder_input2 = ~input2;
    end
  end
  adder a (
      .input1(input1),
      .input2(adder_input2),
      .C_in  (add_bar_sub),
      .result(adder_result)
  );

  wire [31:0] logic_unit_result;
  logic_unit l (
      .input1    (input1),
      .input2    (input2),
      .logic_func(logic_func),
      .result    (logic_unit_result)
  );

  wire arithmetic;
  assign arithmetic = (func_class == 2'b10);
  flags f (
      .clk       (clk),
      .rst       (rst),
      .input1    (adder_result),
      .arithmetic(arithmetic),
      .zero_flag (zero_flag),
      .sign_flag (sign_flag)
  );

  always @(*) begin
    case (func_class)
      2'b00:   result = padder_result;
      2'b01:   result = shifter_result;
      2'b10:   result = adder_result;
      2'b11:   result = logic_unit_result;
      default: result = 32'sb0;
    endcase
  end
endmodule

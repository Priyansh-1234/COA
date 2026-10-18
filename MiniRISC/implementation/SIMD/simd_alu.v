module simd_alu (
    input  wire        [127:0] input1,
    input  wire        [127:0] input2,
    input  wire signed [ 31:0] rs,
    input  wire signed [ 31:0] imm,
    input  wire                splat_src,
    input  wire                add_bar_sub,
    input  wire        [  1:0] logic_func,
    input  wire        [  1:0] func_class,
    input  wire                reduction,
    output wire        [127:0] result,
    output wire        [ 31:0] splat_result
);
  wire signed [31:0] subalu_input1[0:3];
  wire signed [31:0] subalu_input2[0:3];
  wire signed [31:0] sub_result[0:3];

  assign subalu_input1[0] = input1[127:96];
  assign subalu_input2[0] = (reduction == 0) ? input2[127:96] : input1[95:64];

  assign subalu_input1[1] = (reduction == 0) ? input1[95:64] : sub_result[0];
  assign subalu_input2[1] = (reduction == 0) ? input2[95:64] : sub_result[2];

  assign subalu_input1[2] = input1[63:32];
  assign subalu_input2[2] = (reduction == 0) ? input2[63:32] : input1[31:0];

  assign subalu_input1[3] = input1[31:0];
  assign subalu_input2[3] = input2[31:0];


  genvar index;
  generate
    for (index = 0; index < 4; index = index + 1) begin : gen_sub_alus
      sub_alu s (
          .input1     (subalu_input1[index]),
          .input2     (subalu_input2[index]),
          .rs         (rs),
          .imm        (imm),
          .add_bar_sub(add_bar_sub),
          .splat_src  (splat_src),
          .logic_func (logic_func),
          .func_class (func_class),
          .result     (sub_result[index])
      );
    end
  endgenerate

  assign result = {sub_result[0], sub_result[1], sub_result[2], sub_result[3]};
  assign splat_result = sub_result[1];
endmodule

module padder (
    input  wire signed [31:0] input1,
    output wire signed [31:0] result
);
  assign result = {input1[15:0], 16'b0};
endmodule

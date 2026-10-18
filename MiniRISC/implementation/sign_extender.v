module sign_extender (
    input  wire signed [15:0] input1,
    output wire signed [31:0] result
);
  assign result = {{16{input1[15]}}, input1[15:0]};
endmodule

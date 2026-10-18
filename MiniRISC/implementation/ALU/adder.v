module adder (
    input  wire signed [31:0] input1,
    input  wire signed [31:0] input2,
    input  wire               C_in,
    output wire signed [31:0] result
);
  assign result = input1 + input2 + C_in;
endmodule

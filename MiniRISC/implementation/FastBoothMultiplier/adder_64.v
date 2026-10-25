module adder_64 (
    input  wire [63:0] A,
    input  wire [63:0] B,
    output wire [63:0] C
);
  assign C = A + B;
endmodule

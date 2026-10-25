module carry_save_adder (
    input  wire [63:0] X,
    input  wire [63:0] Y,
    input  wire [63:0] Z,
    output wire [63:0] S,
    output wire [63:0] C
);
  assign S = X ^ Y ^ Z;
  assign C = (X & Y) | (Y & Z) | (X & Z);
endmodule

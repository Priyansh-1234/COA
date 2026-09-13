module half_adder (
    output wire Sum,
    output wire Carry,
    input  wire A,
    input  wire B
);
  assign Sum   = A ^ B;
  assign Carry = A & B;
endmodule

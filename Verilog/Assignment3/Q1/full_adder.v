module full_adder (
    output wire Sum,
    output wire Cout,
    input  wire A,
    input  wire B,
    input  wire Cin
);
  wire int_sum, carry1, carry2;

  half_adder HA1 (
      .Sum(int_sum),
      .Carry(carry1),
      .A(A),
      .B(B)
  );

  half_adder HA2 (
      .Sum(Sum),
      .Carry(carry2),
      .A(int_sum),
      .B(Cin)
  );

  assign Cout = carry1 | carry2;
endmodule

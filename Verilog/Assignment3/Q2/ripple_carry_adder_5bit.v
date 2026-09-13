module ripple_carry_adder_5bit (
    output wire [5:0] Sum,
    input  wire [4:0] A,
    input  wire [4:0] B
);

  wire carry0, carry1, carry2, carry3;

  full_adder FA0 (
      .Sum(Sum[0]),
      .Cout(carry0),
      .A(A[0]),
      .B(B[0]),
      .Cin(1'b0)
  );
  full_adder FA1 (
      .Sum(Sum[1]),
      .Cout(carry1),
      .A(A[1]),
      .B(B[1]),
      .Cin(carry0)
  );

  full_adder FA2 (
      .Sum(Sum[2]),
      .Cout(carry2),
      .A(A[2]),
      .B(B[2]),
      .Cin(carry1)
  );

  full_adder FA3 (
      .Sum(Sum[3]),
      .Cout(carry3),
      .A(A[3]),
      .B(B[3]),
      .Cin(carry2)
  );

  full_adder FA4 (
      .Sum(Sum[4]),
      .Cout(Sum[5]),
      .A(A[4]),
      .B(B[4]),
      .Cin(carry3)
  );
endmodule

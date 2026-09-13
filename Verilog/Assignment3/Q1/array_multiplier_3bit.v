module array_multiplier_3bit (
    input  wire [2:0] A,
    input  wire [2:0] B,
    output wire [5:0] P
);
  wire P22, P21, P20, P12, P11, P10, P02, P01, P00;
  assign P22  = A[2] & B[2];
  assign P21  = A[2] & B[1];
  assign P20  = A[2] & B[0];
  assign P12  = A[1] & B[2];
  assign P11  = A[1] & B[1];
  assign P10  = A[1] & B[0];
  assign P02  = A[0] & B[2];
  assign P01  = A[0] & B[1];
  assign P00  = A[0] & B[0];

  assign P[0] = P00;

  wire C1, C2A, C2B, C3A, C3B;
  wire S2, S3;
  half_adder HA1 (
      .Sum(P[1]),
      .Carry(C1),
      .A(P10),
      .B(P01)
  );

  full_adder FA1 (
      .Sum(S2),
      .Cout(C2A),
      .A(P20),
      .B(P11),
      .Cin(P02)
  );

  half_adder HA2 (
      .Sum(P[2]),
      .Carry(C2B),
      .A(S2),
      .B(C1)
  );

  full_adder FA2 (
      .Sum(S3),
      .Cout(C3A),
      .A(P21),
      .B(P12),
      .Cin(C2A)
  );

  half_adder HA3 (
      .Sum(P[3]),
      .Carry(C3B),
      .A(S3),
      .B(C2B)
  );

  full_adder FA3 (
      .Sum(P[4]),
      .Cout(P[5]),
      .A(P22),
      .B(C3A),
      .Cin(C3B)
  );
endmodule

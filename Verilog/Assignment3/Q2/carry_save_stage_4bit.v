module carry_save_stage_4bit (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire [3:0] C,
    output wire [3:0] S,
    output wire [3:0] Carry
);
  full_adder FA0 (
      .Sum(S[0]),
      .Cout(Carry[0]),
      .A(A[0]),
      .B(B[0]),
      .Cin(C[0])
  );

  full_adder FA1 (
      .Sum(S[1]),
      .Cout(Carry[1]),
      .A(A[1]),
      .B(B[1]),
      .Cin(C[1])
  );

  full_adder FA2 (
      .Sum(S[2]),
      .Cout(Carry[2]),
      .A(A[2]),
      .B(B[2]),
      .Cin(C[2])
  );

  full_adder FA3 (
      .Sum(S[3]),
      .Cout(Carry[3]),
      .A(A[3]),
      .B(B[3]),
      .Cin(C[3])
  );
endmodule

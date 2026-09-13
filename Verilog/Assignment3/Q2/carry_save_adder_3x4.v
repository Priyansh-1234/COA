module carry_save_adder_3x4 (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire [3:0] C,
    output wire [5:0] Result
);
  wire [3:0] S;
  wire [3:0] Carry;

  carry_save_stage_4bit CSS4 (
      .A(A),
      .B(B),
      .C(C),
      .S(S),
      .Carry(Carry)
  );

  wire [4:0] S_ext;
  wire [4:0] Carry_shifted;

  assign S_ext = {1'b0, S};
  assign Carry_shifted = {Carry, 1'b0};

  ripple_carry_adder_5bit RCA5 (
      .Sum(Result),
      .A  (S_ext),
      .B  (Carry_shifted)
  );
endmodule

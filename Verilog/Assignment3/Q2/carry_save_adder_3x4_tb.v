`timescale 1ns / 1ps

module carry_save_adder_3x4_tb;
  reg  [3:0] A;
  reg  [3:0] B;
  reg  [3:0] C;

  wire [5:0] Result;

  carry_save_adder_3x4 uut (
      .A(A),
      .B(B),
      .C(C),
      .Result(Result)
  );

  initial begin
    $dumpfile("carry_save_adder_waves.vcd");
    $dumpvars(0, carry_save_adder_3x4_tb);

    $display("Time\tA\tB\tC\tResult");
    $display("-----------------------------------------------------------------");
    $monitor("%0t\t%d\t%d\t%d\t%d", $time, A, B, C, Result);

    A = 4'b0000;
    B = 4'b0000;
    C = 4'b0000;
    #10;

    A = 4'b0001;
    B = 4'b0010;
    C = 4'b0000;
    #10;

    A = 4'b0001;
    B = 4'b0010;
    C = 4'b0010;
    #10;

    A = 4'b0011;
    B = 4'b0100;
    C = 4'b0001;
    #10;

    A = 4'b1001;
    B = 4'b0100;
    C = 4'b0010;
    #10;

    A = 4'b1000;
    B = 4'b0100;
    C = 4'b0001;
    #10;

    A = 4'b0001;
    B = 4'b0011;
    C = 4'b0111;
    #10;

    A = 4'b0011;
    B = 4'b0111;
    C = 4'b1111;
    #10;

    A = 4'b0011;
    B = 4'b0110;
    C = 4'b1111;
    #10;

    A = 4'b1111;
    B = 4'b1111;
    C = 4'b1111;
    #10;
    $finish;
  end
endmodule

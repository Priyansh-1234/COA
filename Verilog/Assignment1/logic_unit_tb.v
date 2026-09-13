/* ------------------------------------------------------------
 *  Group Number: 62
 *  Group Members (Name and Roll Number):
 *  1. Priyansh Pranjal     24CS10024
 *  2. Allu Gowri Sasaank   24CS10054
 *  Course: Computer Organization and Architecture Laboratory
 *  Assignment: Verilog Assignment 1
 *  Question: 1
 *  Problem: Hierarchical Design of a 4-bit Combinational Logic Unit
 *  Module: logic_unit_tb
 *  Date: 12-8-2026
 * ------------------------------------------------------------
 */
`timescale 1ns / 1ps

module logic_unit_tb;
  // Inputs are declared as reg to drive values inside procedural blocks
  reg  [3:0] A;
  reg  [3:0] B;
  reg  [1:0] sel;

  // Outputs are declared as wire
  wire [4:0] Y;

  // Instantiate the Unit Under Test (UUT)
  logic_unit uut (
      .Y  (Y),
      .A  (A),
      .B  (B),
      .sel(sel)
  );

  initial begin
    // 1. Setup waveform dumping for GTKWave / Vivado
    $dumpfile("logic_unit_waves.vcd");
    $dumpvars(0, logic_unit_tb);

    // Print a header to the terminal
    $display("Time\tsel\tA\tB\t|\tY\t(Operation)");
    $display("-----------------------------------------------------------------");
    // $monitor automatically prints to the terminal whenever a listed variable changes
    $monitor("%0t\t%b\t%d\t%d\t|\t%d", $time, sel, A, B, Y);

    // 2. Test Cases

    // Addition (sel = 00)
    sel = 2'b00;
    A   = 4'd5;
    B   = 4'd3;
    #10;
    A = 4'd15;
    B = 4'd1;
    #10;  // Verifies carry-out (15 + 1 = 16)

    // Bitwise AND (sel = 01)
    sel = 2'b01;
    A   = 4'b1100;
    B   = 4'b1010;
    #10;  // Expected: 1000 (8 in decimal)

    // Bitwise OR (sel = 10)
    sel = 2'b10;
    A   = 4'b0101;
    B   = 4'b0011;
    #10;  // Expected: 0111 (7 in decimal)

    // Bitwise XOR (sel = 11)
    sel = 2'b11;
    A   = 4'b1111;
    B   = 4'b1010;
    #10;  // Expected: 0101 (5 in decimal)

    // 3. End simulation
    $finish;
  end
endmodule

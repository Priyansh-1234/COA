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

module code_converter_top_tb;
  // Inputs are declared as reg to drive values inside procedural blocks
  reg  [3:0] binary_in;

  // Outputs are declared as wire
  wire [3:0] gray_out;
  wire [3:0] binary_recovered;

  // Instantiate the Unit Under Test (UUT)
  code_converter_top uut (
      .binary_in(binary_in),
      .gray_out(gray_out),
      .binary_recovered(binary_recovered)
  );

  initial begin
    $dumpfile("code_converter_top_waves.vcd");
    $dumpvars(0, code_converter_top_tb);

    $display("Time\tBinary In\tGray out\tBinary recovered\t");
    $display("-----------------------------------------------------------------");
    $monitor("%0t\t%b\t%b\t%b", $time, binary_in, gray_out, binary_recovered);


    binary_in = 4'd00;
    #10;
    binary_in = 4'd01;
    #10;
    binary_in = 4'd02;
    #10;
    binary_in = 4'd03;
    #10;
    binary_in = 4'd04;
    #10;
    binary_in = 4'd05;
    #10;
    binary_in = 4'd06;
    #10;
    binary_in = 4'd07;
    #10;
    binary_in = 4'd08;
    #10;
    binary_in = 4'd09;
    #10;
    binary_in = 4'd10;
    #10;
    binary_in = 4'd11;
    #10;
    binary_in = 4'd12;
    #10;
    binary_in = 4'd13;
    #10;
    binary_in = 4'd14;
    #10;
    binary_in = 4'd15;
    #10;

    $finish;
  end
endmodule

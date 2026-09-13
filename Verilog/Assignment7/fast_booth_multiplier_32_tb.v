// <====================================>
//  Group No.           : 62
//  Group Members       :
//                        * Priyansh Pranjal     24CS10024
//                        * Allu Gowri Sasaank   24CS10054
//
//  Assignment Name     : 32-bit Signed Fast Booth Multiplier Using Carry-Save Reduction
//  Module Name         : fast_booth_multiplier_32_tb
//  Date of Submission  : 07-09-2026
// <====================================>

`timescale 1ns / 1ps

module fast_booth_multiplier_32_tb;
  reg                clk;
  reg                reset;
  reg                start;
  reg signed  [31:0] multiplicand;
  reg signed  [31:0] multiplier;
  wire signed [63:0] product;
  wire               busy;
  wire               done;

  fast_booth_multiplier_32 uut (
      .clk         (clk),
      .reset       (reset),
      .start       (start),
      .multiplicand(multiplicand),
      .multiplier  (multiplier),
      .product     (product),
      .busy        (busy),
      .done        (done)
  );

  always #5 clk = ~clk;

  task automatic test;
    input signed [31:0] a;
    input signed [31:0] b;
    input signed [63:0] expected;
    begin
      @(negedge clk);
      multiplicand = a;
      multiplier   = b;
      start        = 1;
      @(negedge clk);
      start = 0;
      wait (done == 1'b1);
      @(negedge clk);
      if (product === expected) begin
        $display("PASS: %d * %d = %d", a, b, product);
      end else begin
        $display("FAIL: %d * %d. Expected: %d, Got: %d", a, b, expected, product);
      end
    end
  endtask

  initial begin
    $dumpfile("fast_booth_waves.vcd");
    $dumpvars(0, fast_booth_multiplier_32_tb);

    clk          = 0;
    reset        = 1;
    start        = 0;
    multiplicand = 0;
    multiplier   = 0;

    #20 reset = 0;

    test(13, -22, -286);
    test(100, 25, 2500);
    test(-100, 25, -2500);
    test(-100, -25, 2500);
    test(0, 123456, 0);
    test(1, -123456, -123456);
    test(2147483647, 1, 2147483647);
    test(-2147483648, 1, -2147483648);
    test(-2147483648, -1, 64'd2147483648);
    test(-15234, 9821, -15234 * 9821);
    test(2147483647, 2147483647, 64'sh3FFFFFFF00000001);
    test(-2147483648, -2147483648, 64'sh4000000000000000);

    #50 $finish;
  end
endmodule

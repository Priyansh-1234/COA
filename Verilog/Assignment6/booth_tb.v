`timescale 1ns / 1ps

module booth_tb;
  reg clk;
  reg reset;
  reg start;
  reg signed [3:0] multiplicand;
  reg signed [3:0] multiplier;
  reg display_sel;

  wire [15:0] led;

  booth_multiplier_4bit #(
      .DIV_BIT(0)
  ) uut (
      .clk(clk),
      .reset(reset),
      .start(start),
      .multiplicand(multiplicand),
      .multiplier(multiplier),
      .display_sel(display_sel),
      .led(led)
  );

  always #1 clk = ~clk;

  initial begin
    $dumpfile("booth_multiplier_4bit_waves.vcd");
    $dumpvars(0, booth_tb);

    clk = 0;
    reset = 1;
    start = 0;
    multiplicand = 0;
    multiplier = 0;
    display_sel = 0;
    #10;

    reset = 0;
    #10;

    multiplicand = 4'sd3;
    multiplier = 4'sd2;
    start = 1;
    #4;
    start = 0;
    #20;
    display_sel = 1;
    #10;
    $display("Test 1: %0d * %0d = %0d (led = %b)", multiplicand, multiplier, $signed(led[7:0]),
             led);

    display_sel = 0;
    multiplicand = 4'sd3;
    multiplier = -4'sd2;
    start = 1;
    #4;
    start = 0;
    #20;
    display_sel = 1;
    #10;
    $display("Test 2: %0d * %0d = %0d (led = %b)", multiplicand, multiplier, $signed(led[7:0]),
             led);

    display_sel = 0;
    multiplicand = -4'sd3;
    multiplier = 4'sd2;
    start = 1;
    #4;
    start = 0;
    #20;
    display_sel = 1;
    #10;
    $display("Test 3: %0d * %0d = %0d (led = %b)", multiplicand, multiplier, $signed(led[7:0]),
             led);

    display_sel = 0;
    multiplicand = -4'sd3;
    multiplier = -4'sd2;
    start = 1;
    #4;
    start = 0;
    #20;
    display_sel = 1;
    #10;
    $display("Test 4: %0d * %0d = %0d (led = %b)", multiplicand, multiplier, $signed(led[7:0]),
             led);

    display_sel = 0;
    multiplicand = 4'sd7;
    multiplier = 4'sd3;
    start = 1;
    #4;
    start = 0;
    #20;
    display_sel = 1;
    #10;
    $display("Test 5: %0d * %0d = %0d (led = %b)", multiplicand, multiplier, $signed(led[7:0]),
             led);

    display_sel = 0;
    multiplicand = -4'sd8;
    multiplier = 4'sd1;
    start = 1;
    #4;
    start = 0;
    #20;
    display_sel = 1;
    #10;
    $display("Test 6: %0d * %0d = %0d (led = %b)", multiplicand, multiplier, $signed(led[7:0]),
             led);

    display_sel = 0;
    multiplicand = 4'sd7;
    multiplier = -4'sd8;
    start = 1;
    #4;
    start = 0;
    #20;
    display_sel = 1;
    #10;
    $display("Test 7: %0d * %0d = %0d (led = %b)", multiplicand, multiplier, $signed(led[7:0]),
             led);

    display_sel = 0;
    multiplicand = -4'sd8;
    multiplier = -4'sd8;
    start = 1;
    #4;
    start = 0;
    #20;
    display_sel = 1;
    #10;
    $display("Test 8: %0d * %0d = %0d (led = %b)", multiplicand, multiplier, $signed(led[7:0]),
             led);

    #20;
    $finish;
  end

endmodule

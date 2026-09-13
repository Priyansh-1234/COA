`timescale 1ns / 1ps

module bidirectional_tb;
  reg clk;
  reg reset;
  reg enable;
  reg direction;

  wire [4:0] led;

  bidirectional_led_shift uut(
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .direction(direction),
    .led(led)
  );

  always #1 clk = ~clk;

  initial begin
    $dumpfile("bidirectional_led_shift_waves.vcd");
    $dumpvars(0, bidirectional_tb);

    $display("time\tled[4]\tled[3]\tled[2]\tled[1]\tled[0]");
    $monitor("%0t\t%b\t%b\t%b\t%b\t%b", $time, led[4], led[3], led[2], led[1], led[0]);

    clk = 0;
    reset = 1;
    enable = 0;
    direction = 0;
    #100;

    reset = 0;
    enable = 1;
    #10;
    #10;
    #10;

    direction = 1;
    #10;
    #10;
    #10;

    reset = 1;
    #10;
    reset = 0;
    #10;
    #10;
    #10;
    $finish;
  end
endmodule

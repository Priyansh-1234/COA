module bidirectional_led_shift (
    input wire clk,
    input wire reset,
    input wire enable,
    input wire direction,
    output reg [4:0] led
);
  wire slow_clk;
  clock_divider div (
      .clk(clk),
      .slow_clk(slow_clk)
  );

  always @(posedge slow_clk or posedge reset) begin
    if (reset) begin
      led[4] <= 0;
      led[3] <= 0;
      led[2] <= 0;
      led[1] <= 0;
      led[0] <= 1;
    end else if (enable) begin
      if (direction) begin
        led[4] <= led[0];
        led[3] <= led[4];
        led[2] <= led[3];
        led[1] <= led[2];
        led[0] <= led[1];
      end else begin
        led[0] <= led[4];
        led[4] <= led[3];
        led[3] <= led[2];
        led[2] <= led[1];
        led[1] <= led[0];
      end
    end
  end
endmodule

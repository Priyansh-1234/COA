module clock_divider (
    input  wire clk,
    output wire slow_clk
);
  reg [1:0] clk_div = 2'b00;

  always @(posedge clk) begin
    clk_div <= clk_div + 1'b1;
  end

  assign slow_clk = clk_div[0];
endmodule

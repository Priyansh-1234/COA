module clock_divider #(
    parameter DIV_BIT = 25
) (
    input  wire clk,
    output wire slow_clk
);
  reg [25:0] clk_div = 26'b0;

  always @(posedge clk) begin
    clk_div <= clk_div + 1'b1;
  end

  assign slow_clk = clk_div[DIV_BIT];
endmodule

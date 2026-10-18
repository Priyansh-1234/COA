module pc_unit (
    input  wire        clk,
    input  wire        rst,
    input  wire        pc_en,
    input  wire [31:0] pc_input,
    output reg  [31:0] result
);

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      result <= 32'd0;
    end else if (pc_en) begin
      result <= pc_input;
    end else begin
      result <= result;
    end
  end
endmodule

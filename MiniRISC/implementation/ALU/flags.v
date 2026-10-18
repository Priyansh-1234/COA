module flags (
    input  wire               clk,
    input  wire               rst,
    input  wire signed [31:0] input1,
    input  wire               arithmetic,
    output reg                zero_flag,
    output reg                sign_flag
);
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      zero_flag <= 0;
      sign_flag <= 0;
    end else begin
      if (arithmetic) begin
        zero_flag <= ~|input1;
        sign_flag <= input1[31];
      end else begin
        zero_flag <= zero_flag;
        sign_flag <= sign_flag;
      end
    end
  end
endmodule

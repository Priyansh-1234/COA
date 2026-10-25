module register_file_4x128 (
    input  wire         clk,
    input  wire         rst,
    input  wire [  1:0] rs_addr,
    input  wire [  1:0] rt_addr,
    input  wire [  1:0] rd_addr,
    input  wire         macv,
    input  wire [  1:0] write_addr,
    input  wire [127:0] write_data,
    input  wire         write_en,
    output wire [127:0] result1,
    output wire [127:0] result2
);
  reg [127:0] regs[3:0];
  integer i;

  wire [1:0] r_addr;
  assign r_addr  = (macv == 0) ? rs_addr : rd_addr;
  assign result1 = regs[r_addr];
  assign result2 = regs[rt_addr];

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      for (i = 0; i < 4; i = i + 1) begin
        regs[i] <= 128'd0;
      end
    end else begin
      if (write_en) begin
        regs[write_addr] <= write_data;
      end
    end
  end
endmodule

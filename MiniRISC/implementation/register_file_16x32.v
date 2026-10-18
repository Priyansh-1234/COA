module register_file_16x32 (
    input  wire        clk,
    input  wire        rst,
    input  wire [ 3:0] rs_addr,
    input  wire [ 3:0] rt_addr,
    input  wire [ 3:0] rd_addr,
    input  wire        mac,
    input  wire [ 3:0] write_addr,
    input  wire [31:0] write_data,
    input  wire        write_en,
    output wire [31:0] result1,
    output wire [31:0] result2
);
  reg [31:0] regs[15:0];
  integer i;

  wire [3:0] r_addr;
  assign r_addr  = (mac == 0) ? rs_addr : rd_addr;
  assign result1 = (r_addr == 4'd0) ? 32'd0 : regs[r_addr];
  assign result2 = (rt_addr == 4'd0) ? 32'd0 : regs[rt_addr];

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      for (i = 0; i < 16; i = i + 1) begin
        regs[i] <= 32'd0;
      end
    end else begin
      if (write_en && (write_addr != 4'd0)) begin
        regs[write_addr] <= write_data;
      end
    end
  end
endmodule

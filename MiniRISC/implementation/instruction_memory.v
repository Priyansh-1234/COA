module instruction_memory (
    input  wire        clk,
    input  wire        rst,
    input  wire        fetch,
    input  wire [31:0] pc,
    output wire [ 7:0] opcode,
    output wire [ 3:0] rs_addr,
    output wire [ 3:0] rt_addr,
    output wire [ 3:0] rd_addr,
    output wire [ 4:0] shamt,
    output wire [ 6:0] funct,
    output wire [15:0] imm,
    output wire [23:0] jta
);
  wire [31:0] instruction_wire;
  reg  [31:0] instruction_register;

  instruction_rom rom (
      .clka (~clk),
      .addra(pc[13:2]),
      .douta(instruction_wire)
  );

  assign opcode  = instruction_register[31:24];
  assign rs_addr = instruction_register[23:20];
  assign rt_addr = instruction_register[19:16];
  assign rd_addr = instruction_register[15:12];
  assign shamt   = instruction_register[11:7];
  assign funct   = instruction_register[6:0];
  assign imm     = instruction_register[15:0];
  assign jta     = instruction_register[23:0];

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      instruction_register <= 32'b11000000000000000000000000000000;
    end else if (fetch) begin
      instruction_register <= instruction_wire;
    end else begin
      instruction_register <= instruction_register;
    end
  end
endmodule

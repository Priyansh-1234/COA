module next_addr (
    input  wire [31:0] pc,
    input  wire [15:0] imm,
    input  wire [23:0] jta,
    input  wire [31:0] rs,
    input  wire        branch,
    input  wire [ 1:0] br_type,
    input  wire        zero_flag,
    input  wire        sign_flag,
    input  wire [ 1:0] pc_src,
    output reg  [31:0] next_pc,
    output reg  [31:0] incr_pc
);
  reg zero, non_zero, greater, lesser_equal;
  always @(*) begin
    zero         = zero_flag;
    non_zero     = ~zero_flag;
    greater      = (~zero_flag) & (~sign_flag);
    lesser_equal = zero_flag | sign_flag;
  end

  reg take_branch;
  always @(*) begin
    case (br_type)
      2'b00:   take_branch = zero;
      2'b01:   take_branch = non_zero;
      2'b10:   take_branch = greater;
      2'b11:   take_branch = lesser_equal;
      default: take_branch = 1'b0;
    endcase
  end

  reg [29:0] adder_result;
  always @(*) begin
    if (branch && take_branch) begin
      adder_result = pc[31:2] + 1 + {{14{imm[15]}}, imm[15:0]};
    end else begin
      adder_result = pc[31:2] + 1;
    end
  end

  wire [29:0] jta_result;
  assign jta_result = {adder_result[29:24], jta[23:0]};

  always @(*) begin
    case (pc_src)
      2'b00:   next_pc = {adder_result[29:0], 2'b00};
      2'b01:   next_pc = {jta_result[29:0], 2'b00};
      2'b10:   next_pc = {rs[31:2], 2'b00};
      default: next_pc = 32'b0;
    endcase
    incr_pc = {adder_result[29:0], 2'b00};
  end
endmodule

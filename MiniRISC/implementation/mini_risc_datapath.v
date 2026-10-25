module mini_risc_datapath (
    input  wire       clk,
    input  wire       rst,
    input  wire       branch,
    input  wire [1:0] br_type,
    input  wire [1:0] pc_src,
    input  wire       pc_en,
    input  wire       fetch,
    input  wire [1:0] reg32_dst,
    input  wire       mac,
    input  wire       rf32_en,
    input  wire       macv,
    input  wire       rf128_en,
    input  wire [1:0] alu32_src,
    input  wire       alu128_src,
    input  wire [2:0] incr_value,
    input  wire       add_bar_sub,
    input  wire       shift_src,
    input  wire [1:0] shifter_func,
    input  wire [2:0] logic_func,
    input  wire [1:0] func_class,
    input  wire       splat_src,
    input  wire       reduction,
    input  wire [1:0] width_type,
    input  wire       en,
    input  wire       we,
    input  wire [2:0] reg32_src,
    input  wire [1:0] reg128_src,
    input  wire       mul_start,
    input  wire       mulv_start,
    output wire       mul_done,
    output wire       mulv_done,
    output wire       zero_flag,
    output wire       sign_flag,
    output wire [7:0] opcode,
    output wire [6:0] funct
);
  wire [ 31:0] pc;
  wire [ 31:0] next_pc;
  wire [ 31:0] incr_pc;

  wire [  3:0] rs_addr;
  wire [  3:0] rt_addr;
  wire [  3:0] rd_addr;
  wire [  4:0] shamt;

  wire [ 15:0] imm;
  wire [ 23:0] jta;

  reg  [  3:0] write_addr;
  wire [ 31:0] rs;
  wire [ 31:0] rt;
  wire [ 31:0] rd;

  wire [127:0] vs;
  wire [127:0] vt;

  wire [ 31:0] imm_se;

  wire [ 63:0] mul_product;
  wire         mul_busy;
  wire [ 31:0] mul_result;
  wire [ 31:0] increment_value;

  wire [127:0] mul128_result;
  wire         mulv_busy;

  reg  [ 31:0] alu32_input2;
  wire [ 31:0] alu32_result;

  wire [127:0] alu128_input2;
  wire [127:0] alu128_result;
  wire [ 31:0] splat_result;

  wire [127:0] data128;
  wire [ 31:0] data32;

  reg  [ 31:0] write_data;
  reg  [127:0] write_data_v;

  next_addr addr (
      .pc       (pc),
      .imm      (imm),
      .jta      (jta),
      .rs       (rs),
      .branch   (branch),
      .br_type  (br_type),
      .zero_flag(zero_flag),
      .sign_flag(sign_flag),
      .pc_src   (pc_src),
      .next_pc  (next_pc),
      .incr_pc  (incr_pc)
  );

  pc_unit pcu (
      .clk     (clk),
      .rst     (rst),
      .pc_en   (pc_en),
      .pc_input(next_pc),
      .result  (pc)
  );

  instruction_memory instruction (
      .clk    (clk),
      .rst    (rst),
      .fetch  (fetch),
      .pc     (pc),
      .opcode (opcode),
      .rs_addr(rs_addr),
      .rt_addr(rt_addr),
      .rd_addr(rd_addr),
      .shamt  (shamt),
      .funct  (funct),
      .imm    (imm),
      .jta    (jta)
  );

  always @(*) begin
    case (reg32_dst)
      2'b00:   write_addr = rd_addr;
      2'b01:   write_addr = rt_addr;
      2'b10:   write_addr = 4'd15;
      2'b11:   write_addr = rs_addr;
      default: write_addr = 4'd15;
    endcase
  end
  register_file_16x32 rf32 (
      .clk       (clk),
      .rst       (rst),
      .rs_addr   (rs_addr),
      .rt_addr   (rt_addr),
      .rd_addr   (rd_addr),
      .mac       (mac),
      .write_addr(write_addr),
      .write_data(write_data),
      .write_en  (rf32_en),
      .result1   (rs),
      .result2   (rt)
  );

  register_file_4x128 rf128 (
      .clk       (clk),
      .rst       (rst),
      .rs_addr   (rs_addr),
      .rt_addr   (rt_addr),
      .rd_addr   (rd_addr),
      .macv      (macv),
      .write_addr(write_addr),
      .write_data(write_data_v),
      .write_en  (rf128_en),
      .result1   (vs),
      .result2   (vt)
  );

  sign_extender se (
      .input1(imm),
      .result(imm_se)
  );

  fast_booth_multiplier multiplier_unit (
      .clk         (clk),
      .rst         (rst),
      .start       (mul_start),
      .multiplicand(rs),
      .multiplier  (rt),
      .product     (mul_product),
      .busy        (mul_busy),
      .done        (mul_done)
  );

  assign mul_result = mul_product[31:0];

  vector_multiplier vector_multiplier_unit (
      .clk         (clk),
      .rst         (rst),
      .start       (mulv_start),
      .multiplicand(vs),
      .multiplier  (vt),
      .product     (mul128_result),
      .busy        (mulv_busy),
      .done        (mulv_done)
  );

  assign increment_value = {29'd0, incr_value};

  always @(*) begin
    case (alu32_src)
      2'b00:   alu32_input2 = rt;
      2'b01:   alu32_input2 = imm_se;
      2'b10:   alu32_input2 = mul_result;
      2'b11:   alu32_input2 = increment_value;
      default: alu32_input2 = 32'd0;
    endcase
  end

  alu a (
      .clk        (clk),
      .rst        (rst),
      .input1     (rs),
      .input2     (alu32_input2),
      .shamt      (shamt),
      .add_bar_sub(add_bar_sub),
      .shift_src  (shift_src),
      .shift_func (shifter_func),
      .logic_func (logic_func),
      .func_class (func_class),
      .zero_flag  (zero_flag),
      .sign_flag  (sign_flag),
      .result     (alu32_result)
  );

  assign alu128_input2 = (alu128_src == 1'b0) ? vt : mul128_result;

  simd_alu sa (
      .input1      (vs),
      .input2      (alu128_input2),
      .rs          (rs),
      .imm         (imm_se),
      .splat_src   (splat_src),
      .add_bar_sub (add_bar_sub),
      .logic_func  (logic_func),
      .func_class  (func_class),
      .reduction   (reduction),
      .result      (alu128_result),
      .splat_result(splat_result)
  );

  data_memory data (
      .clk              (clk),
      .rst              (rst),
      .address          (alu32_result),
      .width_type       (width_type),
      .en               (en),
      .we               (we),
      .write_data_scalar(rt),
      .write_data_vector(vt),
      .vector_data      (data128),
      .data             (data32)
  );

  always @(*) begin
    case (reg32_src)
      3'b000:  write_data = splat_result;
      3'b001:  write_data = rs;
      3'b010:  write_data = alu32_result;
      3'b011:  write_data = data32;
      3'b100:  write_data = incr_pc;
      3'b101:  write_data = mul_result;
      default: write_data = 32'd0;
    endcase

    case (reg128_src)
      2'b00:   write_data_v = alu128_result;
      2'b01:   write_data_v = data128;
      2'b10:   write_data_v = mul128_result;
      default: write_data_v = 128'd0;
    endcase
  end
endmodule

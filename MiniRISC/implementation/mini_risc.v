module mini_risc (
    input wire clk,
    input wire rst
);

  wire       branch;
  wire [1:0] br_type;
  wire [1:0] pc_src;

  wire       pc_en;

  wire       fetch;

  wire [1:0] reg32_dst;
  wire       mac;
  wire       rf32_en;
  wire       macv;
  wire       rf128_en;

  wire [1:0] alu32_src;
  wire [2:0] incr_value;

  wire       add_bar_sub;
  wire       shift_src;
  wire [1:0] shifter_func;
  wire [2:0] logic_func;
  wire [1:0] func_class;

  wire       splat_src;
  wire       reduction;

  wire [1:0] width_type;
  wire       en;
  wire       we;

  wire [2:0] reg32_src;
  wire       reg128_src;
  wire       zero_flag;
  wire       sign_flag;
  wire [7:0] opcode;
  wire [6:0] funct;

  mini_risc_datapath datapath (
      .clk         (clk),
      .rst         (rst),
      .branch      (branch),
      .br_type     (br_type),
      .pc_src      (pc_src),
      .pc_en       (pc_en),
      .fetch       (fetch),
      .reg32_dst   (reg32_dst),
      .mac         (mac),
      .rf32_en     (rf32_en),
      .macv        (macv),
      .rf128_en    (rf128_en),
      .alu32_src   (alu32_src),
      .incr_value  (incr_value),
      .add_bar_sub (add_bar_sub),
      .shift_src   (shift_src),
      .shifter_func(shifter_func),
      .logic_func  (logic_func),
      .func_class  (func_class),
      .splat_src   (splat_src),
      .reduction   (reduction),
      .width_type  (width_type),
      .en          (en),
      .we          (we),
      .reg32_src   (reg32_src),
      .reg128_src  (reg128_src),
      .zero_flag   (zero_flag),
      .sign_flag   (sign_flag),
      .opcode      (opcode),
      .funct       (funct)
  );

  mini_risc_controlpath controlpath (
      .clk         (clk),
      .rst         (rst),
      .opcode      (opcode),
      .funct       (funct),
      .zero_flag   (zero_flag),
      .sign_flag   (sign_flag),
      .branch      (branch),
      .br_type     (br_type),
      .pc_src      (pc_src),
      .pc_en       (pc_en),
      .fetch       (fetch),
      .reg32_dst   (reg32_dst),
      .mac         (mac),
      .rf32_en     (rf32_en),
      .macv        (macv),
      .rf128_en    (rf128_en),
      .alu32_src   (alu32_src),
      .incr_value  (incr_value),
      .add_bar_sub (add_bar_sub),
      .shift_src   (shift_src),
      .shifter_func(shifter_func),
      .logic_func  (logic_func),
      .func_class  (func_class),
      .splat_src   (splat_src),
      .reduction   (reduction),
      .width_type  (width_type),
      .en          (en),
      .we          (we),
      .reg32_src   (reg32_src),
      .reg128_src  (reg128_src)
  );
endmodule

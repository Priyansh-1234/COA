module mini_risc_controlpath (
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] opcode,
    input  wire [6:0] funct,
    input  wire       zero_flag,
    input  wire       sign_flag,
    output reg        branch,
    output reg  [1:0] br_type,
    output reg  [1:0] pc_src,
    output reg        pc_en,
    output reg        fetch,
    output reg  [1:0] reg32_dst,
    output reg        mac,
    output reg        rf32_en,
    output reg        macv,
    output reg        rf128_en,
    output reg  [1:0] alu32_src,
    output reg  [2:0] incr_value,
    output reg        add_bar_sub,
    output reg        shift_src,
    output reg  [1:0] shifter_func,
    output reg  [2:0] logic_func,
    output reg  [1:0] func_class,
    output reg        splat_src,
    output reg        reduction,
    output reg  [1:0] width_type,
    output reg        en,
    output reg        we,
    output reg  [2:0] reg32_src,
    output reg        reg128_src
);

  localparam S_FETCH     = 4'd0;
  localparam S_DECODE    = 4'd1;
  localparam S_EX_ALU    = 4'd2;
  localparam S_EX_SIMD   = 4'd3;
  localparam S_EX_MUL    = 4'd4;
  localparam S_BRANCH    = 4'd5;
  localparam S_JUMP      = 4'd6;
  localparam S_MEM_ADDR  = 4'd7;
  localparam S_MEM_READ  = 4'd8;
  localparam S_MEM_WB    = 4'd9;
  localparam S_MEM_WRITE = 4'd10;
  localparam S_AUTO_INCR = 4'd11;
  localparam S_DECJ_DEC  = 4'd12;
  localparam S_DECJ_BR   = 4'd13;
  localparam S_HALT      = 4'd14;

  reg [3:0] current_state, next_state;

  wire [1:0] inst_type = opcode[7:6];
  wire [2:0] r_wb_src = opcode[5:3];
  wire [1:0] i_wb_src = opcode[5:4];
  wire       is_load = opcode[2];
  wire       is_auto_inc = opcode[3];

  reg        cmov_cond;
  always @(*) begin
    case (1'b1)
      funct[6]: cmov_cond = zero_flag;
      funct[5]: cmov_cond = ~zero_flag;
      funct[4]: cmov_cond = (~zero_flag) & (~sign_flag);
      funct[3]: cmov_cond = (~zero_flag) & sign_flag;
      default:  cmov_cond = 1'b0;
    endcase
  end

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      current_state <= S_FETCH;
    end else begin
      current_state <= next_state;
    end
  end

  always @(*) begin
    next_state = S_FETCH;

    case (current_state)
      S_FETCH: begin
        next_state = S_DECODE;
      end

      S_DECODE: begin
        case (inst_type)
          2'b11: begin
            if (opcode[7:5] == 3'b111) begin
              next_state = S_HALT;
            end else begin
              next_state = S_FETCH;
            end
          end

          2'b10: begin
            if (opcode[5]) begin
              next_state = S_BRANCH;
            end else begin
              next_state = S_JUMP;
            end
          end

          2'b00: begin
            case (r_wb_src)
              3'b000:  next_state = S_EX_SIMD;
              3'b001:  next_state = S_EX_ALU;
              3'b010:  next_state = S_EX_ALU;
              3'b100:  next_state = S_JUMP;
              3'b101:  next_state = S_EX_MUL;
              default: next_state = S_FETCH;
            endcase
          end

          2'b01: begin
            case (i_wb_src)
              2'b00:   next_state = S_EX_SIMD;
              2'b10: begin
                if (opcode[3:0] == 4'b1110) begin
                  next_state = S_DECJ_DEC;
                end else begin
                  next_state = S_EX_ALU;
                end
              end
              2'b11:   next_state = S_MEM_ADDR;
              default: next_state = S_FETCH;
            endcase
          end

          default: next_state = S_FETCH;
        endcase
      end

      S_EX_ALU: begin
        next_state = S_FETCH;
      end

      S_EX_SIMD: begin
        next_state = S_FETCH;
      end

      S_EX_MUL: begin
        next_state = S_FETCH;
      end

      S_BRANCH: begin
        next_state = S_FETCH;
      end

      S_JUMP: begin
        next_state = S_FETCH;
      end

      S_MEM_ADDR: begin
        if (is_load) begin
          next_state = S_MEM_READ;
        end else begin
          next_state = S_MEM_WRITE;
        end
      end

      S_MEM_READ: begin
        next_state = S_MEM_WB;
      end

      S_MEM_WB: begin
        if (is_auto_inc) begin
          next_state = S_AUTO_INCR;
        end else begin
          next_state = S_FETCH;
        end
      end

      S_MEM_WRITE: begin
        if (is_auto_inc) begin
          next_state = S_AUTO_INCR;
        end else begin
          next_state = S_FETCH;
        end
      end

      S_AUTO_INCR: begin
        next_state = S_FETCH;
      end

      S_DECJ_DEC: begin
        next_state = S_DECJ_BR;
      end

      S_DECJ_BR: begin
        next_state = S_FETCH;
      end

      S_HALT: begin
        next_state = S_HALT;
      end

      default: begin
        next_state = S_FETCH;
      end
    endcase
  end

  always @(*) begin
    branch       = 1'b0;
    br_type      = 2'b00;
    pc_src       = 2'b00;
    pc_en        = 1'b0;
    fetch        = 1'b0;
    reg32_dst    = 2'b00;
    mac          = 1'b0;
    rf32_en      = 1'b0;
    macv         = 1'b0;
    rf128_en     = 1'b0;
    alu32_src    = 2'b00;
    incr_value   = 3'b000;
    add_bar_sub  = 1'b0;
    shift_src    = 1'b0;
    shifter_func = 2'b00;
    logic_func   = 3'b000;
    func_class   = 2'b00;
    splat_src    = 1'b0;
    reduction    = 1'b0;
    width_type   = 2'b00;
    en           = 1'b0;
    we           = 1'b0;
    reg32_src    = 3'b000;
    reg128_src   = 1'b0;

    case (current_state)
      S_FETCH: begin
        fetch = 1'b1;
        pc_en = 1'b0;
      end

      S_DECODE: begin
        fetch = 1'b0;
        if (inst_type == 2'b11 && opcode[7:5] == 3'b110) begin
          pc_en  = 1'b1;
          pc_src = 2'b00;
          branch = 1'b0;
        end
      end

      S_EX_ALU: begin
        pc_en  = 1'b1;
        pc_src = 2'b00;
        branch = 1'b0;

        if (inst_type == 2'b00) begin
          if (r_wb_src == 3'b001) begin
            reg32_src = 3'b001;
            reg32_dst = 2'b00;
            rf32_en   = cmov_cond;
          end else begin
            alu32_src    = 2'b00;
            func_class   = opcode[1:0];
            add_bar_sub  = funct[6];
            logic_func   = funct[5:3];
            shift_src    = funct[2];
            shifter_func = funct[1:0];
            reg32_src    = 3'b010;
            reg32_dst    = 2'b00;
            rf32_en      = opcode[2];
          end
        end else if (inst_type == 2'b01) begin
          alu32_src   = 2'b01;
          func_class  = opcode[1:0];
          add_bar_sub = opcode[3] & opcode[2];
          logic_func  = {1'b0, opcode[3:2]};
          reg32_src   = 3'b010;
          reg32_dst   = 2'b01;
          rf32_en     = 1'b1;
        end
      end

      S_EX_SIMD: begin
        pc_en  = 1'b1;
        pc_src = 2'b00;
        branch = 1'b0;

        if (inst_type == 2'b01) begin
          splat_src  = opcode[2];
          func_class = opcode[1:0];
          reduction  = 1'b0;
          reg128_src = 1'b0;
          rf128_en   = 1'b1;
        end else begin
          reduction = opcode[2];
          if (opcode[2] == 1'b0) begin
            func_class  = opcode[1:0];
            add_bar_sub = funct[6];
            logic_func  = {1'b0, funct[5:4]};
            splat_src   = funct[3];
            reg128_src  = 1'b0;
            rf128_en    = 1'b1;
          end else begin
            func_class  = opcode[1:0];
            add_bar_sub = funct[6];
            logic_func  = {1'b0, funct[5:4]};
            reg32_src   = 3'b000;
            reg32_dst   = 2'b00;
            rf32_en     = 1'b1;
          end
        end
      end

      S_EX_MUL: begin
        reg32_src = 3'b101;
        reg32_dst = 2'b00;
        rf32_en   = 1'b1;
        pc_en     = 1'b1;
        pc_src    = 2'b00;
        branch    = 1'b0;
      end

      S_BRANCH: begin
        branch  = 1'b1;
        br_type = opcode[3:2];
        pc_src  = 2'b00;
        pc_en   = 1'b1;
      end

      S_JUMP: begin
        if (inst_type == 2'b00) begin
          pc_src = 2'b10;
          pc_en  = 1'b1;
          branch = 1'b0;
        end else begin
          pc_src = 2'b01;
          pc_en  = 1'b1;
          branch = 1'b0;

          if (opcode[4]) begin
            reg32_dst = 2'b10;
            reg32_src = 3'b100;
            rf32_en   = 1'b1;
          end
        end
      end

      S_MEM_ADDR: begin
        alu32_src   = 2'b01;
        add_bar_sub = 1'b0;
        func_class  = 2'b10;
        width_type  = opcode[1:0];
      end

      S_MEM_READ: begin
        alu32_src   = 2'b01;
        add_bar_sub = 1'b0;
        func_class  = 2'b10;
        width_type  = opcode[1:0];
        en          = 1'b1;
        we          = 1'b0;
      end

      S_MEM_WB: begin
        alu32_src   = 2'b01;
        add_bar_sub = 1'b0;
        func_class  = 2'b10;
        width_type  = opcode[1:0];
        en          = 1'b1;
        we          = 1'b0;
        reg32_dst   = 2'b01;

        if (opcode[1:0] == 2'b10) begin
          reg128_src = 1'b1;
          rf128_en   = 1'b1;
        end else begin
          reg32_src = 3'b011;
          rf32_en   = 1'b1;
        end

        if (!is_auto_inc) begin
          pc_en  = 1'b1;
          pc_src = 2'b00;
          branch = 1'b0;
        end
      end

      S_MEM_WRITE: begin
        alu32_src   = 2'b01;
        add_bar_sub = 1'b0;
        func_class  = 2'b10;
        width_type  = opcode[1:0];
        en          = 1'b1;
        we          = 1'b1;

        if (!is_auto_inc) begin
          pc_en  = 1'b1;
          pc_src = 2'b00;
          branch = 1'b0;
        end
      end

      S_AUTO_INCR: begin
        alu32_src   = 2'b11;
        incr_value  = (opcode[1:0] == 2'b00) ? 3'd1 : 3'd4;
        add_bar_sub = 1'b0;
        func_class  = 2'b10;
        reg32_src   = 3'b010;
        reg32_dst   = 2'b11;
        rf32_en     = 1'b1;
        pc_en       = 1'b1;
        pc_src      = 2'b00;
        branch      = 1'b0;
      end

      S_DECJ_DEC: begin
        alu32_src   = 2'b11;
        incr_value  = 3'd1;
        add_bar_sub = 1'b1;
        func_class  = 2'b10;
        reg32_src   = 3'b010;
        reg32_dst   = 2'b11;
        rf32_en     = 1'b1;
        pc_en       = 1'b0;
      end

      S_DECJ_BR: begin
        branch  = 1'b1;
        br_type = 2'b01;
        pc_src  = 2'b00;
        pc_en   = 1'b1;
      end

      S_HALT: begin
        fetch = 1'b0;
        pc_en = 1'b0;
      end

      default: begin
        fetch = 1'b0;
        pc_en = 1'b0;
      end
    endcase
  end

endmodule

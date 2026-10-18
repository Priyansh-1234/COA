module data_memory (
    input  wire         clk,
    input  wire         rst,
    input  wire [ 31:0] address,
    input  wire [  1:0] width_type,
    input  wire         en,
    input  wire         we,
    input  wire [ 31:0] write_data_scalar,
    input  wire [127:0] write_data_vector,
    output wire [127:0] vector_data,
    output reg  [ 31:0] data
);

  wire [13:0] addra = address[17:4];
  wire [15:0] addrb = address[17:2];
  wire [ 1:0] byte_offset = address[1:0];

  reg  [15:0] wea;
  reg  [ 3:0] web;
  reg  [31:0] aligned_dinb;

  always @(*) begin
    wea = 16'b0;
    web = 4'b0;
    aligned_dinb = 32'b0;

    if (we && en) begin
      case (width_type)
        2'b00: begin
          web = 4'b0001 << byte_offset;
          aligned_dinb = {24'b0, write_data_scalar[7:0]} << (byte_offset * 8);
        end
        2'b01: begin
          web = 4'b1111;
          aligned_dinb = write_data_scalar;
        end
        2'b10: begin
          wea = 16'hFFFF;
        end
        default: begin
          wea = 16'b0;
          web = 4'b0;
        end
      endcase
    end
  end

  reg [1:0] read_offset_reg;
  reg [1:0] read_width_reg;

  always @(posedge clk) begin
    if (rst) begin
      read_offset_reg <= 2'b0;
      read_width_reg  <= 2'b0;
    end else if (en) begin
      read_offset_reg <= byte_offset;
      read_width_reg  <= width_type;
    end
  end

  wire [31:0] doutb_wire;
  wire        ena_sig = en && (width_type == 2'b10);
  wire        enb_sig = en && (width_type != 2'b10);

  data_ram ram (
      .clka (clk),
      .ena  (ena_sig),
      .wea  (wea),
      .addra(addra),
      .dina (write_data_vector),
      .douta(vector_data),
      .clkb (clk),
      .enb  (enb_sig),
      .web  (web),
      .addrb(addrb),
      .dinb (aligned_dinb),
      .doutb(doutb_wire)
  );

  always @(*) begin
    data = 32'b0;
    case (read_width_reg)
      2'b00:   data = {24'b0, doutb_wire[(read_offset_reg*8)+:8]};
      2'b01:   data = doutb_wire;
      default: data = 32'b0;
    endcase
  end

endmodule

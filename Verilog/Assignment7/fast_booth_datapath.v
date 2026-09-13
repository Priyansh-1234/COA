// <====================================>
//  Group No.           : 62
//  Group Members       :
//                        * Priyansh Pranjal     24CS10024
//                        * Allu Gowri Sasaank   24CS10054
//
//  Assignment Name     : 32-bit Signed Fast Booth Multiplier Using Carry-Save Reduction
//  Module Name         : fast_booth_datapath
//  Date of Submission  : 07-09-2026
// <====================================>

module fast_booth_datapath (
    input  wire               clk,
    input  wire               reset,
    input  wire               load_inputs,
    input  wire               load_product,
    input  wire signed [31:0] multiplicand,
    input  wire signed [31:0] multiplier,
    output reg signed  [63:0] product
);
  reg signed [31:0] multiplicand_register;
  reg signed [31:0] multiplier_register;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      multiplicand_register <= 32'd0;
      multiplier_register   <= 32'd0;
    end else if (load_inputs) begin
      multiplicand_register <= multiplicand;
      multiplier_register   <= multiplier;
    end
  end

  wire [32:0] Q = {multiplier_register, 1'b0};
  wire [15:0] zero;
  wire [15:0] negate;
  wire [15:0] double;

  genvar index;
  generate
    for (index = 0; index < 16; index = index + 1) begin : gen_booth_signals
      booth_encoder_radix4 encoder (
          .Q_2   (Q[2*index+2]),
          .Q_1   (Q[2*index+1]),
          .Q_0   (Q[2*index]),
          .zero  (zero[index]),
          .negate(negate[index]),
          .double(double[index])
      );
    end
  endgenerate

  wire [15:0][63:0] partial_products;
  generate
    for (index = 0; index < 16; index = index + 1) begin : gen_partial_products
      partial_product_generator pp_generator (
          .multiplicand   (multiplicand_register),
          .index          (index[3:0]),
          .zero           (zero[index]),
          .negate         (negate[index]),
          .double         (double[index]),
          .partial_product(partial_products[index])
      );
    end
  endgenerate

  wire [63:0] negate_result = {
    33'd0,
    negate[15],
    1'b0,
    negate[14],
    1'b0,
    negate[13],
    1'b0,
    negate[12],
    1'b0,
    negate[11],
    1'b0,
    negate[10],
    1'b0,
    negate[9],
    1'b0,
    negate[8],
    1'b0,
    negate[7],
    1'b0,
    negate[6],
    1'b0,
    negate[5],
    1'b0,
    negate[4],
    1'b0,
    negate[3],
    1'b0,
    negate[2],
    1'b0,
    negate[1],
    1'b0,
    negate[0]
  };

  wire [63:0] S_00;
  wire [63:0] C_00;
  carry_save_adder_64 CSA_00 (
      .X(partial_products[0]),
      .Y(partial_products[1]),
      .Z(partial_products[2]),
      .S(S_00),
      .C(C_00)
  );

  wire [63:0] S_01;
  wire [63:0] C_01;
  carry_save_adder_64 CSA_01 (
      .X(partial_products[3]),
      .Y(partial_products[4]),
      .Z(partial_products[5]),
      .S(S_01),
      .C(C_01)
  );

  wire [63:0] S_02;
  wire [63:0] C_02;
  carry_save_adder_64 CSA_02 (
      .X(partial_products[6]),
      .Y(partial_products[7]),
      .Z(partial_products[8]),
      .S(S_02),
      .C(C_02)
  );

  wire [63:0] S_03;
  wire [63:0] C_03;
  carry_save_adder_64 CSA_03 (
      .X(partial_products[9]),
      .Y(partial_products[10]),
      .Z(partial_products[11]),
      .S(S_03),
      .C(C_03)
  );

  wire [63:0] S_04;
  wire [63:0] C_04;
  carry_save_adder_64 CSA_04 (
      .X(partial_products[12]),
      .Y(partial_products[13]),
      .Z(partial_products[14]),
      .S(S_04),
      .C(C_04)
  );

  wire [63:0] S_10;
  wire [63:0] C_10;
  carry_save_adder_64 CSA_10 (
      .X(S_00),
      .Y(C_00 << 1),
      .Z(S_01),
      .S(S_10),
      .C(C_10)
  );

  wire [63:0] S_11;
  wire [63:0] C_11;
  carry_save_adder_64 CSA_11 (
      .X(C_01 << 1),
      .Y(C_02 << 1),
      .Z(S_02),
      .S(S_11),
      .C(C_11)
  );

  wire [63:0] S_12;
  wire [63:0] C_12;
  carry_save_adder_64 CSA_12 (
      .X(S_03),
      .Y(C_03 << 1),
      .Z(S_04),
      .S(S_12),
      .C(C_12)
  );

  wire [63:0] S_20;
  wire [63:0] C_20;
  carry_save_adder_64 CSA_20 (
      .X(S_10),
      .Y(C_10 << 1),
      .Z(S_11),
      .S(S_20),
      .C(C_20)
  );

  wire [63:0] S_21;
  wire [63:0] C_21;
  carry_save_adder_64 CSA_21 (
      .X(S_12),
      .Y(C_11 << 1),
      .Z(C_12 << 1),
      .S(S_21),
      .C(C_21)
  );

  wire [63:0] S_22;
  wire [63:0] C_22;
  carry_save_adder_64 CSA_22 (
      .X(C_04 << 1),
      .Y(partial_products[15]),
      .Z(negate_result),
      .S(S_22),
      .C(C_22)
  );

  wire [63:0] S_30;
  wire [63:0] C_30;
  carry_save_adder_64 CSA_30 (
      .X(S_20),
      .Y(C_20 << 1),
      .Z(S_21),
      .S(S_30),
      .C(C_30)
  );

  wire [63:0] S_31;
  wire [63:0] C_31;
  carry_save_adder_64 CSA_31 (
      .X(S_22),
      .Y(C_22 << 1),
      .Z(C_21 << 1),
      .S(S_31),
      .C(C_31)
  );

  wire [63:0] S_40;
  wire [63:0] C_40;
  carry_save_adder_64 CSA_40 (
      .X(S_30),
      .Y(C_30 << 1),
      .Z(S_31),
      .S(S_40),
      .C(C_40)
  );
  wire [63:0] S_50;
  wire [63:0] C_50;
  carry_save_adder_64 CSA_50 (
      .X(S_40),
      .Y(C_40 << 1),
      .Z(C_31 << 1),
      .S(S_50),
      .C(C_50)
  );

  wire [63:0] temp_product;
  adder_64 adder (
      .A(S_50),
      .B(C_50 << 1),
      .C(temp_product)
  );

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      product <= 64'd0;
    end else if (load_product) begin
      product <= temp_product;
    end
  end
endmodule

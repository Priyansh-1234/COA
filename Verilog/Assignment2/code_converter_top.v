module code_converter_top (
    input  wire [3:0] binary_in,
    output wire [3:0] gray_out,
    output wire [3:0] binary_recovered
);
  binary_to_gray BTG (
      .B(binary_in),
      .G(gray_out)
  );

  gray_to_binary GTB (
      .B(binary_recovered),
      .G(gray_out)
  );
endmodule



module hamming74_system (
    input wire [3:0] data_in,
    input wire [6:0] error_mask,
    output wire [6:0] encoded_codeword,
    output wire [6:0] received_codeword,
    output wire [2:0] syndrome,
    output wire error_detected
);

  hamming74_encoder encoder (
      .data(data_in),
      .codeword(encoded_codeword)
  );
  assign received_codeword = encoded_codeword ^ error_mask;
  syndrome_generator generator (
      .received(received_codeword),
      .syndrome(syndrome),
      .error_detected(error_detected)
  );
endmodule

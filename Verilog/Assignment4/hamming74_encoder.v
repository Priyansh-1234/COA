module hamming74_encoder (
    input  wire [3:0] data,
    output wire [6:0] codeword
);
  wire p1, p2, p4;
  assign p1 = data[0] ^ data[1] ^ data[3];
  assign p2 = data[0] ^ data[2] ^ data[3];
  assign p4 = data[1] ^ data[2] ^ data[3];
  assign codeword = {data[3], data[2], data[1], p4, data[0], p2, p1};
endmodule

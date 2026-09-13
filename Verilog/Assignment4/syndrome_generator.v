module syndrome_generator (
    input wire [6:0] received,
    output wire [2:0] syndrome,
    output wire error_detected
);
  wire s1, s2, s4;
  assign s1 = received[0] ^ received[2] ^ received[4] ^ received[6];
  assign s2 = received[1] ^ received[2] ^ received[5] ^ received[6];
  assign s4 = received[3] ^ received[4] ^ received[5] ^ received[6];
  assign syndrome = {s4, s2, s1};
  assign error_detected = (s4 | s2 | s1);
endmodule

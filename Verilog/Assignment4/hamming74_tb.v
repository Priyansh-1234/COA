`timescale 1ns / 1ps

module hamming74_tb;
  reg [3:0] data_in;
  reg [6:0] error_mask;
  wire [6:0] encoded_codeword;
  wire [6:0] received_codeword;
  wire [2:0] syndrome;
  wire error_detected;

  hamming74_system uut (
      .data_in(data_in),
      .error_mask(error_mask),
      .encoded_codeword(encoded_codeword),
      .received_codeword(received_codeword),
      .syndrome(syndrome),
      .error_detected(error_detected)
  );

  initial begin
    $dumpfile("hamming74_encoder_waves.vcd");
    $dumpvars(0, hamming74_tb);

    $display("Time\tinput\tmask\tencoded\trecieved\tsyndrome\terror");
    $display("-----------------------------------------------------------------");
    $monitor("%0t\t%d\t%d\t%d\t%d\t\t%d\t\t%d", $time, data_in, error_mask, encoded_codeword,
             received_codeword, syndrome, error_detected);

    data_in = 4'b0000;
    error_mask = 7'b0000000;
    #10;

    data_in = 4'b0100;
    error_mask = 7'b0000000;
    #10;

    data_in = 4'b0101;
    error_mask = 7'b0000000;
    #10;

    data_in = 4'b1010;
    error_mask = 7'b0000000;
    #10;

    data_in = 4'b1101;
    error_mask = 7'b0000001;
    #10;

    data_in = 4'b1001;
    error_mask = 7'b0000010;
    #10;

    data_in = 4'b1000;
    error_mask = 7'b0000100;
    #10;

    data_in = 4'b1111;
    error_mask = 7'b0001000;
    #10;

    data_in = 4'b0110;
    error_mask = 7'b0010000;
    #10;

    data_in = 4'b0010;
    error_mask = 7'b0100000;
    #10;

    data_in = 4'b0010;
    error_mask = 7'b1000000;
    #10;

    $finish;
  end
endmodule

// <====================================>
//  Group No.           : 62
//  Group Members       :
//                        * Priyansh Pranjal     24CS10024
//                        * Allu Gowri Sasaank   24CS10054
//
//  Assignment Name     : 32-bit Signed Fast Booth Multiplier Using Carry-Save Reduction
//  Module Name         : booth_encoder_radix4
//  Date of Submission  : 07-09-2026
// <====================================>

module booth_encoder_radix4 (
    input  wire Q_2,
    input  wire Q_1,
    input  wire Q_0,
    output reg  zero,
    output reg  negate,
    output reg  double
);
  always @(*) begin
    case ({
      Q_2, Q_1, Q_0
    })
      3'b000: begin
        zero   = 1;
        negate = 0;
        double = 0;
      end
      3'b001: begin
        zero   = 0;
        negate = 0;
        double = 0;
      end
      3'b010: begin
        zero   = 0;
        negate = 0;
        double = 0;
      end
      3'b011: begin
        zero   = 0;
        negate = 0;
        double = 1;
      end
      3'b100: begin
        zero   = 0;
        negate = 1;
        double = 1;
      end
      3'b101: begin
        zero   = 0;
        negate = 1;
        double = 0;
      end
      3'b110: begin
        zero   = 0;
        negate = 1;
        double = 0;
      end
      3'b111: begin
        zero   = 1;
        negate = 0;
        double = 0;
      end
      default: begin
        zero   = 1'bx;
        negate = 1'bx;
        double = 1'bx;
      end

    endcase
  end
endmodule

// <====================================>
//  Group No.           : 62
//  Group Members       :
//                        * Priyansh Pranjal     24CS10024
//                        * Allu Gowri Sasaank   24CS10054
//
//  Assignment Name     : 32-bit Signed Fast Booth Multiplier Using Carry-Save Reduction
//  Module Name         : fast_booth_controlpath
//  Date of Submission  : 07-09-2026
// <====================================>

module fast_booth_controlpath (
    input  wire clk,
    input  wire reset,
    input  wire start,
    output reg  busy,
    output reg  done,
    output reg  load_inputs,
    output reg  load_product
);
  localparam reg [1:0] IDLE    = 2'b00;
  localparam reg [1:0] COMPUTE = 2'b01;
  localparam reg [1:0] DONE    = 2'b10;

  reg [1:0] state;
  reg [1:0] next_state;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

  always @(state or start) begin
    load_inputs  = 0;
    load_product = 0;
    busy         = 0;
    done         = 0;
    next_state   = state;

    case (state)
      IDLE: begin
        if (start) begin
          busy        = 1;
          load_inputs = 1;
          next_state  = COMPUTE;
        end
      end
      COMPUTE: begin
        busy = 1;
        load_product = 1;
        next_state = DONE;
      end
      DONE: begin
        done = 1;
        if (!start) begin
          next_state = IDLE;
        end else begin
          load_inputs = 1;
          busy = 1;
          next_state = COMPUTE;
        end
      end
      default: begin
        next_state = IDLE;
      end
    endcase
  end
endmodule

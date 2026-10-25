module fast_booth_controlpath (
    input  wire clk,
    input  wire rst,
    input  wire start,
    output reg  busy,
    output reg  done,
    output reg  load_inputs,
    output reg  load_product
);
  localparam IDLE = 2'b00;
  localparam COMPUTE = 2'b01;
  localparam DONE = 2'b10;

  reg [1:0] current_state;
  reg [1:0] next_state;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
    end
  end

  always @(*) begin
    load_inputs = 0;
    load_product = 0;
    busy = 0;
    done = 0;
    next_state = current_state;

    case (current_state)
      IDLE:
      if (start) begin
        busy = 1;
        load_inputs = 1;
        next_state = COMPUTE;
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
          busy = 1;
          load_inputs = 1;
          next_state = COMPUTE;
        end
      end
      default: begin
        next_state = IDLE;
      end
    endcase
  end
endmodule

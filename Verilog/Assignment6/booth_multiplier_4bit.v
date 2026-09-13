module booth_multiplier_4bit #(
    parameter DIV_BIT = 25
) (
    input  wire        clk,
    input  wire        reset,
    input  wire        start,
    input  wire [ 3:0] multiplicand,
    input  wire [ 3:0] multiplier,
    input  wire        display_sel,
    output wire [15:0] led
);

  localparam [1:0] IDLE = 2'd0, CALC = 2'd1, DONE = 2'd2;
  reg [1:0] state;

  reg [4:0] A;
  reg [4:0] M;
  reg [3:0] Q;
  reg       Q_1;
  reg [2:0] count;
  reg       done;

  wire slow_clk;
  clock_divider #(
      .DIV_BIT(DIV_BIT)
  ) div (
      .clk(clk),
      .slow_clk(slow_clk)
  );

  reg [4:0] A_next;
  always @(*) begin
    case ({Q[0], Q_1})
      2'b01:   A_next = A + M;
      2'b10:   A_next = A - M;
      default: A_next = A;
    endcase
  end

  always @(posedge slow_clk or posedge reset) begin
    if (reset) begin
      state <= IDLE;
      A     <= 5'b00000;
      M     <= 5'b00000;
      Q     <= 4'b0000;
      Q_1   <= 1'b0;
      count <= 3'b000;
      done  <= 1'b0;
    end else begin
      case (state)
        IDLE: begin
          if (start) begin
            state <= CALC;
            A     <= 5'b00000;
            M     <= {{multiplicand[3]}, multiplicand};
            Q     <= multiplier;
            Q_1   <= 1'b0;
            count <= 3'b000;
            done  <= 1'b0;
          end
        end
        CALC: begin
          if (!done) begin
            A     <= {A_next[4], A_next[4:1]};
            Q     <= {A_next[0], Q[3:1]};
            Q_1   <= Q[0];
            count <= count + 1'b1;

            if (count == 3'd3) begin
              done <= 1'b1;
              state <= DONE;
            end
          end
        end
        DONE: begin
          if (!start) begin
            state <= IDLE;
          end
        end
      endcase
    end
  end

  wire [7:0] product = {A[3:0], Q[3:0]};

  assign led = (display_sel == 1'b0) ? {2'b00, done, count, Q_1, Q, A}
                                     : {7'b0000000, done, product};

endmodule

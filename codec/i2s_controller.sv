module i2s_controller (
    input  logic        clk,    // Clock
    input  logic        rst_n,  // Reset, active low
    input  logic [23:0] din,    // 24-bit Audio data input
    output logic [23:0] dout,   // 24-bit Audio data output
    input  logic        ws,     // Word Select
    input  logic        sclk,   // Serial Clock
    inout  wire        sd      // Serial Data
);
  logic [23:0] shift_reg;  // Shift register for transmission
  logic [ 4:0] bit_cnt;  // Counter for 24-bit transmission

  // Transmit logic
  always_ff @(posedge sclk or negedge rst_n) begin
    if (!rst_n) begin
      shift_reg <= 24'd0;
      bit_cnt   <= 5'd0;
    end else if (ws) begin
      sd        <= shift_reg[23];  // Send MSB first
      shift_reg <= {shift_reg[22:0], 1'b0};  // Shift left
      bit_cnt   <= bit_cnt + 1;
    end
  end

  // Receive logic
  always_ff @(negedge sclk or negedge rst_n) begin
    if (!rst_n) begin
      dout <= 24'd0;
      bit_cnt <= 5'd0;
    end else if (!ws) begin
      dout <= {dout[22:0], sd};     // Shift in data (LSB last)
      bit_cnt <= bit_cnt + 1;
    end
  end
endmodule

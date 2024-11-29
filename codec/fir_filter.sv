module fir_filter #(
    parameter TAPS = 5
) (
    input logic clk,
    input logic rst_n,
    input logic signed [23:0] din,  // 24-bit Input data
    output logic signed [23:0] dout  // 24-bit Filtered output
);
  logic signed [23:0] coeff[TAPS-1:0];  // Filter coefficients
  logic signed [23:0] delay_line[TAPS-1:0];
  logic signed [47:0] acc;  // Accumulator for intermediate values

  initial begin
    coeff[0] = 24'h001000;  // Example coefficients
    coeff[1] = 24'h002000;
    coeff[2] = 24'h004000;
    coeff[3] = 24'h002000;
    coeff[4] = 24'h001000;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      acc <= 48'd0;
    end else begin
      acc <= 48'd0;
      for (int i = 0; i < TAPS; i++) begin
        if (i == 0) delay_line[i] <= din;
        else delay_line[i] <= delay_line[i-1];
        acc <= acc + (coeff[i] * delay_line[i]);
      end
      dout <= acc[47:24];  // Normalize back to 24 bits
    end
  end
endmodule

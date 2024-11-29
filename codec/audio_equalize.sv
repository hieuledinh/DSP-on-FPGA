module audio_equalizer (
    input logic clk,
    input logic rst_n,
    input logic ws,     // Word Select
    input logic sclk,   // Serial Clock
    inout logic sda,
    scl,  // I2C signals
    inout logic sd      // I2S signal
);
  logic [23:0] audio_in, audio_out;

  // I2C controller instance for codec configuration
  i2c_controller i2c_inst (
      .clk  (clk),
      .rst_n(rst_n),
      .start(1'b1),
      .addr (8'h34),  // Example address
      .data (8'h12),  // Example data
      .scl  (scl),
      .sda  (sda)
  );

  // I2S controller instance for 24-bit audio
  i2s_controller_24bit i2s_inst (
      .clk(clk),
      .rst_n(rst_n),
      .din(audio_out),
      .dout(audio_in),
      .ws(ws),
      .sclk(sclk),
      .sd(sd)
  );

  // FIR filter instance for 24-bit equalizer
  fir_filter_24bit #(
      .TAPS(5)
  ) fir_inst (
      .clk  (clk),
      .rst_n(rst_n),
      .din  (audio_in),
      .dout (audio_out)
  );
endmodule

module audio_equalizer_wrapper (
    input  logic       CLOCK_50,   // 50MHz clock từ DE10-Standard
    input  logic       RESET_N,    // Reset button (active-low)
    input  logic       I2S_LRCLK,  // I2S left-right clock từ Audio CODEC
    input  logic       I2S_BCLK,   // I2S bit clock từ Audio CODEC
    input  logic       I2S_DIN,    // I2S audio input từ Audio CODEC
    output logic       I2S_DOUT,   // I2S audio output đến Audio CODEC
    inout  logic       I2C_SDA,    // I2C data line
    output logic       I2C_SCL,    // I2C clock line
    input  logic [4:0] SW          // Switch để chọn dải tần (gain control)
    // Keys để điều chỉnh gain
);

  // Internal signals
  logic reset;
  logic config_done;
  logic [23:0] audio_out;
  logic [23:0] audio_in;

  // Assign active-low reset
  assign reset = ~RESET_N;
  i2c_controller i2c_inst (
      .clk(CLOCK_50),
      .reset(reset),
      .i2c_sda(I2C_SDA),
      .i2c_scl(I2C_SCL),
      .config_done(config_done)
  );
  // Instantiate Audio Equalizer System
  topmodel audio_eq_inst (
      .clk(CLOCK_50),
      .reset(reset_n),
      .lrclk(I2S_LRCLK),
      .bclk(I2S_BCLK),
      .sw_gain(SW[2:4]),
      .sw_mode(SW[0:1]),     // Input audio từ I2S
      .data_out(audio_out),
      .i2c_sda(I2C_SDA),
      .i2c_scl(I2C_SCL)   // Processed audio// Configuration done signal
  );
  i2s_controller i2s_inst (
      .clk      (CLOCK_50),
      .reset    (reset),
      .lrclk    (I2S_LRCLK),
      .bclk     (I2S_BCLK),
      .audio_in (I2S_DIN),    // Input từ WM8731
      .audio_out(audio_out),  // Output đến WM8731
      .data_out (I2S_DOUT)    // Kết nối tới Audio CODEC
  );
endmodule

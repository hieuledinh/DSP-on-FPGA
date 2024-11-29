module audio_equalizer_top (
    input  clk_50MHz,  // Clock chính từ DE10-Standard (50 MHz)
    input  reset,      // Reset hệ thống
    output scl,        // Clock I2C
    inout  sda,        // Data I2C
    output bclk,       // Bit Clock (I2S)
    output lrclk,      // Left/Right Clock (I2S)
    output sdin,       // Dữ liệu I2S truyền đi
    input  sdin_in     // Dữ liệu I2S nhận về
);

  // Tín hiệu nội bộ
  wire        config_done;  // Hoàn tất cấu hình I2C
  wire [23:0] audio_in;  // Dữ liệu âm thanh đầu vào (24-bit)
  wire [23:0] audio_out;  // Dữ liệu âm thanh đầu ra (24-bit)
  wire i2s_bclk, i2s_lrclk;

  // Cấu hình WM8731
  wm8731_config wm8731_cfg (
      .clk  (clk_50MHz),
      .reset(reset),
      .scl  (scl),
      .sda  (sda),
      .done (config_done)
  );

  // Bộ tạo tín hiệu I2S Clock
  i2s_clock_generator i2s_clk_gen (
      .clk  (clk_50MHz),
      .bclk (i2s_bclk),
      .lrclk(i2s_lrclk)
  );

  assign bclk  = i2s_bclk;
  assign lrclk = i2s_lrclk;

  // Giao tiếp I2S
  i2s_audio i2s_audio_process (
      .clk(clk_50MHz),
      .bclk(i2s_bclk),
      .lrclk(i2s_lrclk),
      .audio_in(audio_in),
      .audio_out(audio_out),
      .sdin(sdin),
      .sdin_in(sdin_in)
  );
endmodule

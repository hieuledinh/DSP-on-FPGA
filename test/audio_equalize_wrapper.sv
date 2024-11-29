module audio_equalize_wrapper (
    input  logic       CLOCK_50,     // Clock chính 50 MHz từ DE10
    input  logic       RESET_N,      // Reset từ DE10
    input  logic       I2S_DATA_IN,  // Dữ liệu I2S từ CODEC
    input  logic       I2S_BCLK,     // Clock bit từ CODEC
    input  logic       I2S_LRCLK,    // Word Select (trái/phải) từ CODEC
    input  logic [4:0] SW,           // Công tắc chọn gain (bass, mid, high)
    output logic       I2S_CLK,      // Clock I2S tới CODEC
    output logic       I2S_WS,       // Word Select tới CODEC
    output logic       I2S_DATA_OUT  // Dữ liệu I2S tới CODEC
);

  // Tín hiệu nội bộ
  logic [23:0] audio_in;  // Tín hiệu âm thanh đầu vào từ CODEC (giải mã I2S)
  logic [23:0] audio_out;  // Tín hiệu âm thanh sau khi xử lý trong audio_equalizer

  // Giải mã tín hiệu I2S từ CODEC
  i2s_receiver i2s_rx (
      .i2s_data   (I2S_DATA_IN),  // Dữ liệu I2S đầu vào
      .i2s_bclk   (I2S_BCLK),     // Bit Clock từ CODEC
      .i2s_lrclk  (I2S_LRCLK),    // Word Select từ CODEC
      .audio_left (audio_in),     // Kênh trái (được sử dụng làm đầu vào)
      .audio_right()              // Kênh phải (không sử dụng)
  );

  // Xử lý tín hiệu trong audio_equalizer
  audio_equalizer eq (
      .data_in (audio_in),      // Tín hiệu đầu vào từ CODEC
      .i2s_clk (I2S_CLK),       // Clock I2S tới CODEC
      .i2s_ws  (I2S_WS),        // Word Select tới CODEC
      .i2s_data(I2S_DATA_OUT),  // Dữ liệu I2S tới CODEC
      .clk     (CLOCK_50),      // Clock chính
      .reset   (RESET_N),       // Reset tín hiệu
      .sw_gain (SW[4:2]),       // Chọn hệ số gain
      .sw_mode (SW[1:0])        // Chọn chế độ hoạt động
  );

endmodule
